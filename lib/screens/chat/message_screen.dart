import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:master/Model/message_model.dart';
import 'package:master/Model/token_user.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/push_notification/notification.dart';
import 'package:master/databases/database.dart';
import 'package:master/providers/message_provider.dart';
import 'package:master/providers/url_provider.dart';
import 'package:master/services/api/chat_service.dart';
import 'package:master/services/api/token_service.dart';
import 'package:master/services/socket/io_service.dart';
import 'package:master/util/alerts.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/widgets/common/connect_avatar.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../classes/message_class.dart';
import '../../componants/global_booking.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  MessageClass messageClass = MessageClass();
  Authenticate auth = Authenticate();
  TokenUser? currentUser;
  bool isLoading = false;

  // ── Pagination state ──────────────────────────────────────────────────────
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _initialLoadDone = false;

  // ── Local message list — source of truth for the ListView ────────────────
  List<MessageModel> _messages = [];

  late ScrollController scrollController;

  final TextEditingController controller = TextEditingController();
  String messagex = '';
  List<String> processedMessageIds = [];

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    if (mounted) initChat();
  }

  // ── Trigger history load when user scrolls near the top ──────────────────
  // With reverse:true, scrolling UP increases pixels toward maxScrollExtent.
  void _onScroll() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 120 &&
        _hasMore &&
        !_isLoadingMore) {
      _loadMoreMessages();
    }
  }

  // ── Load older messages (page 2, 3, …) ───────────────────────────────────
  // With reverse:true ListView, insertAll(0, newMsgs) adds items at HIGH
  // indices (the top of the visual list). Flutter keeps existing items at
  // their current indices — no scroll jump, no math needed.
  Future<void> _loadMoreMessages() async {
    if (!_hasMore || _isLoadingMore || currentUser == null) return;
    setState(() => _isLoadingMore = true);

    try {
      final result = await ChatService.fetchMessages(
        uniqueId: currentUser!.uniqueChurchId ?? '',
        page: _page + 1,
      );

      final newMsgs = (result['messages'] as List)
          .map((m) => MessageModel.fromJson(
              Map<String, dynamic>.from(m as Map)))
          .toList();
      final pagination = result['pagination'] as Map<String, dynamic>;

      if (!mounted) return;

      setState(() {
        _messages.insertAll(0, newMsgs);
        _page++;
        _hasMore = pagination['hasMore'] as bool? ?? false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> initChat() async {
    setState(() => isLoading = true);
    initCurrentUser();

    Provider.of<MessageProvider>(context, listen: false)
        .addListener(_onMessageUpdate);

    // Call immediately — socket may have already fired before this
    // screen attached its listener, so messages sit in the provider unseen.
    _onMessageUpdate();

    // Safety fallback: hide spinner after 5s if socket never responds.
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && isLoading) setState(() => isLoading = false);
    });
  }

  // ── Sync provider → local list ────────────────────────────────────────────
  // Socket's "initial messages" → provider.addMessages() → this fires.
  // Socket's "new message"      → provider.addMessage()  → this fires.
  void _onMessageUpdate() {
    final providerMsgs =
        Provider.of<MessageProvider>(context, listen: false).messages;

    if (providerMsgs.isEmpty) return;

    if (!_initialLoadDone) {
      _initialLoadDone = true;
      setState(() {
        _messages = List.from(providerMsgs);
        isLoading = false; // dismiss spinner as soon as messages arrive
      });
      _scrollToBottom();
      return;
    }

    // Detect genuinely new messages not already in local list.
    final existingIds = _messages.map((m) => m.id).toSet();
    final newOnes =
        providerMsgs.where((m) => !existingIds.contains(m.id)).toList();

    if (newOnes.isEmpty) return;

    // With reverse:true, pixels=0 is the bottom (newest messages).
    // Scroll to bottom only if user was already there.
    final atBottom = scrollController.hasClients &&
        scrollController.position.pixels <= 80;

    setState(() {
      _messages.addAll(newOnes);
    });

    if (atBottom) _scrollToBottom();
  }

  Future<void> initCurrentUser() async {
    TokenUser? user = await TokenService.tokenUser();
    if (user != null && mounted) {
      setState(() => currentUser = user);
    }
  }

  String parseDateTimeToHourMinute(String timeStamp) {
    final dt = DateTime.parse(timeStamp);
    return '${dt.hour} : ${dt.minute}';
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> deleteMessage({id, uniqueId}) async {
    await ChatService.deleteMessage(id: id, uniqueId: uniqueId);
  }

  Future<void> sendMessage(
      {uniqueId, message, sender, senderId, profileImage, time, church}) async {
    ChatService.sendMessage(
      uniqueId: uniqueId,
      message: message,
      sender: sender,
      senderId: senderId,
      time: time,
      church: church,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        // With reverse:true, 0 is the bottom (newest messages).
        scrollController.jumpTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Subtle top loading bar — fades in/out with _isLoadingMore ──
            AnimatedOpacity(
              opacity: _isLoadingMore ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: LinearProgressIndicator(
                color: AppColors.purple,
                backgroundColor: Colors.transparent,
                minHeight: 2,
              ),
            ),

            // ── Message list ────────────────────────────────────────────────
            Expanded(child: _buildMessageList()),

            // ── Input bar ───────────────────────────────────────────────────
            _ChatInputBar(
              controller: controller,
              onChanged: (value) => setState(() => messagex = value),
              onSend: () async {
                if (messagex.trim().isEmpty) return;
                final toSend = messagex.trim();
                controller.clear();
                FocusScope.of(context).requestFocus(FocusNode());
                setState(() => messagex = '');

                await sendMessage(
                  uniqueId: currentUser?.uniqueChurchId ?? '',
                  message: toSend,
                  sender: currentUser?.userName ?? '',
                  senderId: currentUser?.phoneNumber ?? '',
                  time: DateTime.now().toIso8601String(),
                  church: currentUser?.church ?? '',
                );

                PushNotifications.sendMessageToTopic(
                  topic: currentUser?.uniqueChurchId ?? '',
                  title: currentUser?.userName ?? '',
                  body: toSend,
                );
              },
              isVisible:
                  Provider.of<christProvider>(context, listen: false)
                          .myMap['Project']?['Expire'] ??
                      false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
            color: AppColors.purple, strokeWidth: 2.5),
      );
    }
    if (_messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet.\nSay hello!',
          textAlign: TextAlign.center,
          style: AppTypography.bodyText,
        ),
      );
    }

    // reverse:true means index 0 = newest message (bottom of screen).
    // _messages is chronological (oldest first), so:
    //   index i → _messages[_messages.length - 1 - i]
    // The last slot (index == _messages.length) holds the start-of-history label.
    final itemCount = _messages.length + 1;

    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // ── Last index: start-of-history label (visually at top) ─────
        if (index == _messages.length) {
          if (!_hasMore) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Center(
                child: Text(
                  '— start of conversation —',
                  style: AppTypography.caption.copyWith(fontSize: 10),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        // ── Message bubbles — index 0 = newest ───────────────────────
        final msg = _messages[_messages.length - 1 - index];
        final isSender =
            (msg.phoneNumber ?? '') == (currentUser?.phoneNumber ?? '');

        DateTime? dateTime;
        try {
          dateTime = DateTime.parse(msg.time ?? '');
        } catch (_) {}
        final timeLabel = dateTime != null
            ? '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}'
            : '';

        return isSender
            ? MessageBubbleRight(
                text: msg.message ?? '',
                name: timeLabel,
                image: msg.profileImage ?? '',
                callBack: () => alertDeleteMessage(
                  context,
                  'Delete this message?',
                  () async => deleteMessage(
                      id: msg.id ?? '',
                      uniqueId: msg.uniqueChurchId ?? ''),
                ),
              )
            : MessageBubbleLeft(
                text: msg.message ?? '',
                name: timeLabel,
                image: msg.profileImage ?? '',
                person: msg.sender ?? '',
                callBack: () => alertDeleteMessage(
                  context,
                  'Delete this message?',
                  () async => deleteMessage(
                      id: msg.id ?? '',
                      uniqueId: msg.uniqueChurchId ?? ''),
                ),
              );
      },
    );
  }
}

// ─── Chat Input Bar ───────────────────────────────────────────────────────────
class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final bool isVisible;

  const _ChatInputBar({
    required this.controller,
    required this.onChanged,
    required this.onSend,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(
            color: AppColors.surfaceAlt,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // ── Text field ─────────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                border: Border.all(
                  color: AppColors.surfaceAlt,
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: AppTypography.fieldValue,
                cursorColor: AppColors.purple,
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: AppTypography.fieldPlaceholder,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ── Send button ────────────────────────────────────────────────
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.purpleCardGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                boxShadow: AppSpacing.purpleButtonShadow,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Message Bubble — Other User (Left) ──────────────────────────────────────
class MessageBubbleLeft extends StatelessWidget {
  final String? text;
  final String? name;
  final String? image;
  final String? person;
  final VoidCallback? callBack;

  const MessageBubbleLeft({
    this.text,
    this.image,
    this.name,
    this.person,
    this.callBack,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: callBack ?? () {},
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── Avatar ─────────────────────────────────────────────────
            ConnectAvatar(
              name: person ?? 'U',
              imageUrl: (image != null && image!.isNotEmpty) ? image : null,
              size: AvatarSize.xs,
            ),
            const SizedBox(width: 8),

            // ── Bubble + timestamp ─────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender name
                if (person != null && person!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      person!,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                // Bubble
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.62,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                    child: Text(
                      text ?? '',
                      style: AppTypography.bodyMedium.copyWith(height: 1.45),
                    ),
                  ),
                ),

                // Timestamp
                if (name != null && name!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: Text(
                      name!,
                      style: AppTypography.caption.copyWith(fontSize: 10),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Message Bubble — Own User (Right) ───────────────────────────────────────
class MessageBubbleRight extends StatefulWidget {
  final String? text;
  final String? name;
  final String? image;
  final VoidCallback? callBack;

  const MessageBubbleRight({
    this.text,
    this.name,
    this.image,
    this.callBack,
    super.key,
  });

  @override
  State<MessageBubbleRight> createState() => _MessageBubbleRightState();
}

class _MessageBubbleRightState extends State<MessageBubbleRight> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.callBack ?? () {},
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // ── Bubble + timestamp ─────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Bubble
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.62,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleCardGradient,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.text ?? '',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.white,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),

                // Timestamp
                if (widget.name != null && widget.name!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 4, top: 4),
                    child: Text(
                      widget.name!,
                      style: AppTypography.caption.copyWith(fontSize: 10),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 8),

            // ── Avatar ─────────────────────────────────────────────────
            ConnectAvatar(
              name: 'Me',
              imageUrl: (widget.image != null && widget.image!.isNotEmpty)
                  ? widget.image
                  : null,
              size: AvatarSize.xs,
            ),
          ],
        ),
      ),
    );
  }
}
