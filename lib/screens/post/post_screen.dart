import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/snack_bar.dart';
import 'package:master/providers/url_provider.dart';
import 'package:master/util/alerts.dart';
import 'package:master/util/image_picker_custom.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../classes/church_init.dart';
import '../../classes/on_create_class.dart';
import 'package:provider/provider.dart';
import 'package:master/componants/global_booking.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/theme/app_spacing.dart';
import 'create_post.dart';
import 'package:master/theme/theme_manager.dart';
import 'package:master/widgets/common/connect_loader.dart';

// ── preserved: DisplayImages stream helper ────────────────────────────────────
StreamBuilder xbuildStreamBuilder(context, String path) {
  return StreamBuilder(
    stream: supabase.from('DisplayImages').stream(primaryKey: ['id']).eq(
        "Church",
        Provider.of<christProvider>(context, listen: false).myMap['Project']
            ?['ChurchName']),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.active) {
        if (snapshot.hasError) {
          return Image.network(
            'https://via.placeholder.com/150',
            fit: BoxFit.cover,
          );
        }

        String imageUrl = '';
        try {
          imageUrl = snapshot.data[0]?[path];
        } catch (e) {
          imageUrl = '';
        }

        if (imageUrl.isEmpty) return const SizedBox.shrink();
        return Image.network(imageUrl, fit: BoxFit.cover);
      }
      return const SizedBox.shrink();
    },
  );
}

// ── filter options ─────────────────────────────────────────────────────────────
const _kFilters = ['All', 'Announcements', 'Events', 'Requests', 'Updates'];

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen>
    with AutomaticKeepAliveClientMixin {
  // ── preserved ─────────────────────────────────────────────────────────────
  ChurchInit churchStart = ChurchInit();
  CreateClass create = CreateClass();
  Authenticate auth = Authenticate();
  SnackBarNotice snack = SnackBarNotice();
  ScrollController _scrollController = ScrollController();
  DraggableScrollableController controller = DraggableScrollableController();

  Stream? streamx;
  bool isLoading = false;

  // ── v2 UI state ─────────────────────────────────────────────────────────
  String _selectedFilter = 'All';
  bool _searchActive = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void streamDelegate() {
    streamx = superbasePost();
  }

  // ── preserved: Supabase Posts stream ──────────────────────────────────────
  Stream superbasePost() {
    return supabase
        .from('Posts')
        .stream(primaryKey: ['id'])
        .eq(
            "Church",
            Provider.of<christProvider>(context, listen: false)
                    .myMap['Project']?['ChurchName'] ??
                "")
        .order('id', ascending: false);
  }

  @override
  void initState() {
    super.initState();
    streamDelegate();
    Provider.of<BackImageUrlProvider>(context, listen: false)
        .loadImageUrlLocally();
    Provider.of<ProfileImageUrlProvider>(context, listen: false)
        .loadImageUrlLocally();
  }

  final ImagePickerCustom _picker = ImagePickerCustom();
  Uint8List? _image;

  Future<void> _pickImage() async {
    _image = await _picker.pickImageToByte();
  }

  // ── preserved: upload display image to Supabase ───────────────────────────
  // ignore: unused_element
  Future<void> _uploadImageToSuperbase(String where) async {
    try {
      await _pickImage();
      const message1 = "Display Image Updating...";
      snack.snack(context, message1);

      if (_image != null) {
        final provider = Provider.of<christProvider>(context, listen: false);
        final bucket = provider.myMap['Project']?['Bucket'] ?? "";
        final churchName = provider.myMap['Project']?['ChurchName'];

        final fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';

        try {
          await supabase.storage.from(bucket).remove([fileName]);
        } catch (e) {
          log('No existing image to delete or deletion failed: $e');
        }

        try {
          await supabase
              .from('DisplayImages')
              .delete()
              .eq('Church', churchName);
        } catch (e) {
          log('No existing database row to delete: $e');
        }

        await supabase.storage.from(bucket).uploadBinary(
            fileName, _image!,
            fileOptions:
                const FileOptions(cacheControl: '3600', upsert: false));

        final publicUrl =
            await supabase.storage.from(bucket).getPublicUrl(fileName);

        await supabase.from('DisplayImages').insert({
          'Church': churchName,
          where: publicUrl,
        });

        const message = "Display Image Updated";
        alertComplete(context, message);
        setState(() {});
      } else {
        log("No image selected");
        const message1 = "No Image Selected";
        snack.snack(context, message1);
      }
    } catch (e) {
      log("Error uploading image to Supabase: $e");
      const message2 = "Try Change the name of the Image";
      alertSuccess(context, message2);
    }
  }

  // ── preserved: delete post + comments + image from Supabase ──────────────
  void superbaseDeletePost(String id, String imageUrl) async {
    try {
      await supabase.from('Comments').delete().match({'PostId': id});
      await supabase.from('Posts').delete().match({'id': id});

      if (imageUrl.isNotEmpty) {
        final bucket = Provider.of<christProvider>(context, listen: false)
                .myMap['Project']?['Bucket'] ??
            "";
        final uri = Uri.parse(imageUrl);
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          final startIndex = segments.indexOf(bucket) + 1;
          final filePath = segments.sublist(startIndex).join('/');
          await supabase.storage.from(bucket).remove([filePath]);
        }
      }
    } catch (e) {
      log('Error deleting post, comments, or image: $e');
    }
  }

  @override
  bool get wantKeepAlive => true;

  // ── local filter + search ─────────────────────────────────────────────────
  List _applyFilter(List posts) {
    var result = posts;
    if (_selectedFilter != 'All') {
      result = result
          .where((p) => (p['Category'] ?? '').toString() == _selectedFilter)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) {
        final desc = (p['Description'] ?? '').toString().toLowerCase();
        final title = (p['Title'] ?? '').toString().toLowerCase();
        return desc.contains(q) || title.contains(q);
      }).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = context.watch<ThemeManager>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // ── Navy topbar ───────────────────────────────────────────────
          _PostTopBar(
            searchActive: _searchActive,
            searchController: _searchController,
            onSearchTap: () => setState(() {
              _searchActive = !_searchActive;
              if (!_searchActive) {
                _searchController.clear();
                _searchQuery = '';
              }
            }),
            onSearchChanged: (v) => setState(() => _searchQuery = v),
          ),

          // ── Filter chips ──────────────────────────────────────────────
          Container(
            color: AppColors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _kFilters.map((f) {
                  final sel = _selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? theme.colors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill),
                          border: Border.all(
                            color: sel
                                ? theme.colors.primary
                                : AppColors.surfaceAlt,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          f,
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: sel
                                ? AppColors.white
                                : AppColors.textMid,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Posts feed ────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder(
              stream: streamx,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Connecting...',
                          style: AppTypography.bodyMedium),
                    );
                  } else if (!snapshot.hasData ||
                      snapshot.data.isEmpty == true) {
                    return _EmptyFeed();
                  }

                  final filtered = _applyFilter(snapshot.data as List);
                  if (filtered.isEmpty) return _EmptyFeed();

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final post = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SocialPost(
                          description: post['Description'] ?? '',
                          imageUrl: post['ImageUrl'] ?? '',
                          postId: post['id'].toString(),
                          category: post['Category'] ?? '',
                          onPressedDelete: () {
                            alertDelete(context, "Delete Post?",
                                () async {
                              superbaseDeletePost(
                                post['id'].toString(),
                                post['ImageUrl'] ?? '',
                              );
                              streamDelegate();
                            });
                          },
                        ),
                      );
                    },
                  );
                }
                return Center(
                  child: ConnectLoader(),
                );
              },
            ),
          ),
        ],
      ),

      // ── Primary FAB ─────────────────────────────────────────────────────
      floatingActionButton: Visibility(
        visible: ChurchInit.visibilityToggle(context),
        child: GestureDetector(
          onTap: () => create.sheeting(context, Poster()),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.purpleCardGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colors.primary.withOpacity(0.33),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded,
                color: AppColors.white, size: 26),
          ),
        ),
      ),
    );
  }
}

// ── Topbar ────────────────────────────────────────────────────────────────────
class _PostTopBar extends StatefulWidget {
  final bool searchActive;
  final TextEditingController searchController;
  final VoidCallback onSearchTap;
  final ValueChanged<String> onSearchChanged;

  const _PostTopBar({
    required this.searchActive,
    required this.searchController,
    required this.onSearchTap,
    required this.onSearchChanged,
  });

  @override
  State<_PostTopBar> createState() => _PostTopBarState();
}

class _PostTopBarState extends State<_PostTopBar> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.navy,
      padding: EdgeInsets.fromLTRB(18, top, 18, 13),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: AppSpacing.topBarHeight - 13,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text('Posts',
                      style:
                          AppTypography.screenTitle.copyWith(fontSize: 20)),
                ),
                GestureDetector(
                  onTap: widget.onSearchTap,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: widget.searchActive
                          ? AppColors.purple
                          : AppColors.navyIconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.searchActive ? Icons.close : Icons.search_rounded,
                      size: 18,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.searchActive) ...[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _focused ? AppColors.purple : Colors.transparent,
                  width: 0.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(Icons.search_rounded,
                      size: 16, color: AppColors.purple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: widget.searchController,
                      focusNode: _focusNode,
                      onChanged: widget.onSearchChanged,
                      autofocus: true,
                      style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search posts...',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 13),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Empty feed placeholder ────────────────────────────────────────────────────
class _EmptyFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.purpleTint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.article_outlined,
                size: 30, color: AppColors.purple),
          ),
          const SizedBox(height: 12),
          Text('No posts yet',
              style: AppTypography.headingSmall
                  .copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('Be the first to share something',
              style: AppTypography.caption),
        ],
      ),
    );
  }
}

// ── Social Post card ──────────────────────────────────────────────────────────
class SocialPost extends StatefulWidget {
  final String? description;
  final String imageUrl;
  final String? postId;
  final String category;
  final VoidCallback? onPressedDelete;

  const SocialPost({
    this.description,
    required this.imageUrl,
    this.postId,
    this.category = '',
    this.onPressedDelete,
    Key? key,
  }) : super(key: key);

  @override
  State<SocialPost> createState() => _SocialPostState();
}

class _SocialPostState extends State<SocialPost> {
  // ── preserved ─────────────────────────────────────────────────────────────
  late PostIdProvider postIdProvider;
  ChurchInit churchStart = ChurchInit();

  bool isTextFieldVisible = false;
  TextEditingController textEditingController = TextEditingController();
  Stream? streamComment;

  @override
  void initState() {
    super.initState();
    streamCommentDelegate(widget.postId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    postIdProvider = Provider.of<PostIdProvider>(context, listen: false);
  }

  // ── preserved: comment stream ─────────────────────────────────────────────
  void streamCommentDelegate(postId) {
    streamComment = superbaseCommentStream(postId);
  }

  Stream superbaseCommentStream(postId) {
    return supabase.from('Comments').stream(primaryKey: ['id'])
      ..eq('PostId', postId).order('id', ascending: false);
  }

  // ── preserved: add comment ────────────────────────────────────────────────
  void superbaseComment(String text, String postId) async {
    await supabase
        .from('Comments')
        .insert({'UserName': 'Lungelo', 'Text': text, 'PostId': postId});
  }

  @override
  Widget build(BuildContext context) {
    final churchName =
        Provider.of<christProvider>(context, listen: false)
                .myMap['Project']?['ChurchName'] ??
            'Community';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 6,
              offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                // Org avatar (DisplayImages stream)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.purpleCardGradient,
                  ),
                  child: ClipOval(
                    child: xbuildStreamBuilder(context, "ProfileImage"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(churchName,
                          style: AppTypography.cardTitle
                              .copyWith(fontSize: 13)),
                      Text('Just now',
                          style: AppTypography.caption
                              .copyWith(fontSize: 10)),
                    ],
                  ),
                ),
                // Category badge
                if (widget.category.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.purpleTint,
                      borderRadius: BorderRadius.circular(
                          AppSpacing.radiusPill),
                    ),
                    child: Text(
                      widget.category,
                      style: AppTypography.labelTiny.copyWith(
                          color: AppColors.purple,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                // Delete (admin)
                if (ChurchInit.visibilityToggle(context))
                  GestureDetector(
                    onTap: widget.onPressedDelete,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(Icons.more_vert_rounded,
                          size: 18, color: AppColors.textMuted),
                    ),
                  ),
              ],
            ),
          ),

          // ── Description ───────────────────────────────────────────────
          if ((widget.description ?? '').isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Text(
                widget.description ?? '',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textPrimary, height: 1.5),
              ),
            ),

          // ── Post image ────────────────────────────────────────────────
          if (widget.imageUrl.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(0)),
              child: Image.network(
                widget.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],

          // ── Actions row ───────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                // Comment toggle
                GestureDetector(
                  onTap: () => setState(() {
                    isTextFieldVisible = !isTextFieldVisible;
                    if (!isTextFieldVisible) {
                      textEditingController.clear();
                    }
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 15, color: AppColors.textMid),
                        const SizedBox(width: 5),
                        Text('Comment',
                            style: AppTypography.caption
                                .copyWith(fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Delete (admin only)
                if (ChurchInit.visibilityToggle(context))
                  GestureDetector(
                    onTap: widget.onPressedDelete,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 15, color: AppColors.error),
                          const SizedBox(width: 4),
                          Text('Delete',
                              style: AppTypography.caption.copyWith(
                                  fontSize: 11,
                                  color: AppColors.error)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Comments section (preserved logic, new style) ─────────────
          if (isTextFieldVisible) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              height: 1,
              color: AppColors.surfaceAlt,
            ),
            StreamBuilder(
              stream: streamComment,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active &&
                    snapshot.hasData &&
                    snapshot.data?.isNotEmpty == true) {
                  final comments = snapshot.data!;
                  return SizedBox(
                    height: 120,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                      itemCount: comments.length,
                      itemBuilder: (context, i) =>
                          CommentBubble(
                              lastComment: comments[i]['Text'] ?? ''),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(
                            color: AppColors.surfaceAlt, width: 2),
                      ),
                      child: TextField(
                        controller: textEditingController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Add a comment...',
                          hintStyle: AppTypography.fieldPlaceholder
                              .copyWith(fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          isDense: true,
                        ),
                        style: AppTypography.bodyMedium
                            .copyWith(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      superbaseComment(
                          textEditingController.text, widget.postId!);
                      setState(() {
                        isTextFieldVisible = false;
                        textEditingController.clear();
                      });
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.purpleCardGradient,
                      ),
                      child: const Icon(Icons.send_rounded,
                          size: 18, color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Comment bubble ────────────────────────────────────────────────────────────
class CommentBubble extends StatelessWidget {
  final String lastComment;
  const CommentBubble({super.key, required this.lastComment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.purpleCardGradient,
            ),
            alignment: Alignment.center,
            child: Text('U',
                style: AppTypography.labelTiny.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.purpleTint,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(lastComment,
                  style: AppTypography.bodyMedium.copyWith(
                      fontSize: 12,
                      color: AppColors.textPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}
