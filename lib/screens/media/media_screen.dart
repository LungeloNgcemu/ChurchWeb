import 'package:flutter/material.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/youtube.dart';
import 'package:master/util/alerts.dart';
import '../../classes/church_init.dart';
import '../../classes/on_create_class.dart';
import 'package:master/providers/url_provider.dart';
import 'package:provider/provider.dart';
import 'package:master/componants/global_booking.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/theme/app_spacing.dart';
import 'create_media.dart';
import 'package:master/theme/theme_manager.dart';

// ── Category chips ─────────────────────────────────────────────────────────────
const _kCategories = ['Special', 'Sermon', 'Study', 'Live'];

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen>
    with AutomaticKeepAliveClientMixin {
  // ── preserved ─────────────────────────────────────────────────────────────
  CreateClass create = CreateClass();
  ChurchInit visibility = ChurchInit();
  Authenticate auth = Authenticate();
  YouTube youTube = YouTube();

  @override
  void initState() {
    // ── preserved: init SelectedOptionProvider ─────────────────────────────
    Provider.of<SelectedOptionProvider>(context, listen: false)
        .updateSelectedOption('Special', Colors.grey);
    super.initState();
  }

  // ── preserved: filter media list by category ──────────────────────────────
  List<Map<String, dynamic>> optionMedia(
      String selectedOption, List<Map<String, dynamic>> list) {
    if (selectedOption.isEmpty) return list;
    return list
        .where((item) => item['Category'] == selectedOption)
        .toList();
  }

  // ── preserved: delete video from Supabase ─────────────────────────────────
  void deleteVideo(id) async {
    await supabase.from('Media').delete().eq('id', id);
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<ThemeManager>(); // re-render when theme changes
    final selectedOption =
        context.watch<SelectedOptionProvider>().selectedOption;
    final idProvider = Provider.of<IdProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // ── Topbar ───────────────────────────────────────────────────
          _MediaTopBar(
            onAddTap: ChurchInit.visibilityToggle(context)
                ? () => MediaPoster.show(context)
                : null,
          ),

          // ── Category chips ────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _kCategories.map((cat) {
                  final sel = selectedOption == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        Provider.of<SelectedOptionProvider>(context,
                                listen: false)
                            .updateSelectedOption(cat, Colors.grey);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.purple
                              : AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill),
                          border: Border.all(
                            color: sel
                                ? AppColors.purple
                                : AppColors.surfaceAlt,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: sel
                                ? AppColors.white
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Media list ────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder(
              // ── preserved: Supabase Media stream ─────────────────────
              stream: supabase
                  .from('Media')
                  .stream(primaryKey: ['id'])
                  .eq(
                      "Church",
                      Provider.of<christProvider>(context, listen: false)
                              .myMap['Project']?['ChurchName'] ??
                          "")
                  .order('id', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Connecting...',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textMuted)),
                    );
                  }
                  if (!snapshot.hasData ||
                      snapshot.data?.isEmpty == true) {
                    return _EmptyMedia();
                  }

                  // ── preserved: filter by selected category ────────────
                  final mediaList =
                      optionMedia(selectedOption, snapshot.data ?? []);

                  if (mediaList.isEmpty) return _EmptyMedia();

                  return ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: mediaList.length,
                    itemBuilder: (context, index) {
                      // ── preserved: convert URL + set ID provider ──────
                      final linkId = youTube
                          .convertVideo(mediaList[index]['URL']);
                      idProvider.changeID(linkId);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GestureDetector(
                          onLongPress: () {
                            // ── preserved: admin long-press delete ───────
                            if (ChurchInit.visibilityToggle(context)) {
                              alertDelete(context, "Delete Video?",
                                  () async {
                                deleteVideo(mediaList[index]['id']);
                              });
                            }
                          },
                          // ── preserved: displayYoutubeOnly ─────────────
                          child: youTube.displayYoutubeOnly(
                            linkId,
                            mediaList[index]['Title'] ?? "",
                            mediaList[index]['Description'] ?? "",
                            context,
                          ),
                        ),
                      );
                    },
                  );
                }
                return Center(
                  child: CircularProgressIndicator(
                      color: AppColors.purple),
                );
              },
            ),
          ),
        ],
      ),

      // ── Add media FAB (admin) ───────────────────────────────────────────
      floatingActionButton: Visibility(
        visible: ChurchInit.visibilityToggle(context),
        child: GestureDetector(
          onTap: () => MediaPoster.show(context),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.purple,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withOpacity(0.33),
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

// ── Dark topbar ───────────────────────────────────────────────────────────────
class _MediaTopBar extends StatelessWidget {
  final VoidCallback? onAddTap;
  const _MediaTopBar({this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.topBarHeight + MediaQuery.of(context).padding.top,
      color: AppColors.navy,
      padding: EdgeInsets.fromLTRB(
          18, MediaQuery.of(context).padding.top, 18, 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text('Media',
                style: AppTypography.screenTitle.copyWith(fontSize: 20)),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.navyIconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.search_rounded,
                size: 18, color: AppColors.white),
          ),
          if (onAddTap != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAddTap,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_rounded,
                    size: 18, color: AppColors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Empty media state ─────────────────────────────────────────────────────────
class _EmptyMedia extends StatelessWidget {
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
            child: Icon(Icons.play_circle_outline_rounded,
                size: 30, color: AppColors.purple),
          ),
          const SizedBox(height: 12),
          Text('No videos yet',
              style: AppTypography.headingSmall),
          const SizedBox(height: 4),
          Text('Add your first video above',
              style: AppTypography.caption),
        ],
      ),
    );
  }
}
