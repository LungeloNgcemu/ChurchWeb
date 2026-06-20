import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:master/util/image_compress.dart';
import 'package:master/Model/message_model.dart';
import 'package:master/Model/token_user.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/push_notification/notification.dart';
import 'package:master/providers/message_provider.dart';
import 'package:master/providers/url_provider.dart';
import 'package:master/services/api/chat_service.dart';
import 'package:master/services/api/token_service.dart';
import 'package:master/util/alerts.dart';
import 'package:master/util/screen_tracker.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/widgets/common/connect_avatar.dart';
import 'package:master/widgets/common/connect_loader.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../classes/message_class.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  /// Called by the search panel to scroll to and highlight a message by id.
  static void Function(String msgId)? scrollToMessageId;

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

  List<MessageModel> _messages = [];

  late ScrollController scrollController;
  final TextEditingController controller = TextEditingController();
  String messagex = '';

  // ── Image attachment state ────────────────────────────────────────────────
  Uint8List? _pendingImageBytes;
  String? _pendingImageUrl;
  bool _isUploading = false;

  // ── Per-message GlobalKeys for scroll-to ��────────────────���───────────────
  final Map<String, GlobalKey> _messageKeys = {};
  String? _highlightedMessageId;
  bool _isJumpingToMessage = false;

  // ── Voice recording state ─────────────────────────────────────────────────
  html.MediaRecorder? _mediaRecorder;
  html.MediaStream? _mediaStream;
  final List<html.Blob> _audioBlobs = [];
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  String? _pendingVoiceBlobUrl;
  bool _isUploadingVoice = false;

  @override
  void initState() {
    super.initState();
    ScreenTracker.enter('message');
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    if (mounted) initChat();
    MessageScreen.scrollToMessageId = _scrollToMessageId;
  }

  Future<void> _scrollToMessageId(String msgId) async {
    setState(() => _isJumpingToMessage = true);
    try {
      await _doScrollToMessage(msgId);
    } finally {
      if (mounted) setState(() => _isJumpingToMessage = false);
    }
  }

  /// Waits for the next rendered frame — more reliable than a fixed delay.
  Future<void> _waitForFrame() {
    final c = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) => c.complete());
    return c.future;
  }

  Future<void> _doScrollToMessage(String msgId) async {
    // 1. Load pages until the message is in the list (max 15 pages).
    var idx = _messages.indexWhere((m) => m.id == msgId);
    int attempts = 0;
    while (idx == -1 && _hasMore && attempts < 15) {
      await _loadMoreMessages();
      await _waitForFrame(); // let ListView rebuild with new items
      idx = _messages.indexWhere((m) => m.id == msgId);
      attempts++;
    }
    if (idx == -1 || !mounted) return;

    // 2. Wait one more frame so maxScrollExtent is up to date.
    await _waitForFrame();
    if (!mounted) return;

    // 3. Rough jump: reverse:true list → pixels=0 is newest (bottom).
    //    Older messages sit at higher offsets.
    final reversedIdx = _messages.length - 1 - idx;
    if (scrollController.hasClients) {
      final approx = (reversedIdx * 80.0)
          .clamp(0.0, scrollController.position.maxScrollExtent);
      scrollController.jumpTo(approx);
    }

    // 4. Wait two frames for the item to be built at the new position.
    await _waitForFrame();
    await _waitForFrame();
    if (!mounted) return;

    // 5. Precise scroll once the GlobalKey has a live context.
    final key = _messageKeys[msgId];
    if (key?.currentContext != null) {
      await Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }

    // 6. Highlight flash.
    if (mounted) {
      setState(() => _highlightedMessageId = msgId);
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) setState(() => _highlightedMessageId = null);
      });
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 120 && _hasMore && !_isLoadingMore) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    if (!_hasMore || _isLoadingMore || currentUser == null) return;
    setState(() => _isLoadingMore = true);
    try {
      final result = await ChatService.fetchMessages(
        uniqueId: currentUser!.uniqueChurchId ?? '',
        page: _page + 1,
      );
      final newMsgs = (result['messages'] as List)
          .map((m) => MessageModel.fromJson(Map<String, dynamic>.from(m as Map)))
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
    Provider.of<MessageProvider>(context, listen: false).addListener(_onMessageUpdate);
    _onMessageUpdate();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && isLoading) setState(() => isLoading = false);
    });
  }

  void _onMessageUpdate() {
    final providerMsgs = Provider.of<MessageProvider>(context, listen: false).messages;
    if (providerMsgs.isEmpty) return;

    if (!_initialLoadDone) {
      _initialLoadDone = true;
      setState(() {
        _messages = List.from(providerMsgs);
        isLoading = false;
      });
      _scrollToBottom();
      return;
    }

    final existingIds = _messages.map((m) => m.id).toSet();
    final newOnes = providerMsgs.where((m) => !existingIds.contains(m.id)).toList();
    if (newOnes.isEmpty) return;

    final atBottom = scrollController.hasClients && scrollController.position.pixels <= 80;
    setState(() => _messages.addAll(newOnes));
    if (atBottom) _scrollToBottom();
  }

  Future<void> initCurrentUser() async {
    final user = await TokenService.tokenUser();
    if (user != null && mounted) setState(() => currentUser = user);
  }

  @override
  void dispose() {
    ScreenTracker.exit('message');
    _recordingTimer?.cancel();
    try { _mediaRecorder?.stop(); } catch (_) {}
    _mediaStream?.getTracks().forEach((t) => t.stop());
    if (_pendingVoiceBlobUrl != null) {
      html.Url.revokeObjectUrl(_pendingVoiceBlobUrl!);
    }
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  // ── Image pick & upload ────────────────────────────────────────────────────
  Future<void> _pickAndUploadImage() async {
    final Uint8List? bytes = await ImagePickerWeb.getImageAsBytes();
    if (bytes == null || !mounted) return;
    final compressed = await compressImageBytes(bytes);
    setState(() {
      _pendingImageBytes = compressed;
      _pendingImageUrl = null;
      _isUploading = true;
    });
    try {
      final path = 'chat/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Supabase.instance.client.storage.from('churchStorage').uploadBinary(
        path, compressed,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      final url = Supabase.instance.client.storage.from('churchStorage').getPublicUrl(path);
      if (mounted) setState(() => _pendingImageUrl = url);
    } catch (e) {
      if (mounted) {
        setState(() { _pendingImageBytes = null; _pendingImageUrl = null; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ── Voice recording (dart:html MediaRecorder — no plugin layer) ──────────
  Future<void> _startRecording() async {
    if (_isRecording) return;
    _audioBlobs.clear();

    try {
      final stream = await html.window.navigator.mediaDevices!
          .getUserMedia({'audio': true});
      _mediaStream = stream;
      _mediaRecorder = html.MediaRecorder(stream, {
        'mimeType': 'audio/webm;codecs=opus',
        'audioBitsPerSecond': 16000,
      });

      _mediaRecorder!.addEventListener('dataavailable', (html.Event event) {
        try {
          final blob = js_util.getProperty<html.Blob>(event, 'data');
          debugPrint('[Voice] dataavailable: ${blob.size} bytes');
          if (blob.size > 0) _audioBlobs.add(blob);
        } catch (e) { debugPrint('[Voice] dataavailable error: $e'); }
      });

      _mediaRecorder!.start(); // no timeslice — single chunk delivered on stop()

      if (!mounted) {
        _mediaRecorder!.stop();
        stream.getTracks().forEach((t) => t.stop());
        return;
      }

      setState(() { _isRecording = true; _recordingSeconds = 0; });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() => _recordingSeconds++);
        if (_recordingSeconds >= 30) _stopRecording();
      });
    } catch (e) {
      debugPrint('[Voice] start error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not access microphone: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _mediaRecorder == null) return;
    _recordingTimer?.cancel();
    _recordingTimer = null;

    final recorder = _mediaRecorder!;
    final stream = _mediaStream;
    _mediaRecorder = null;
    _mediaStream = null;

    final completer = Completer<void>();

    recorder.addEventListener('stop', (_) {
      // Stop mic tracks AFTER final dataavailable fires
      stream?.getTracks().forEach((t) => t.stop());

      if (_audioBlobs.isEmpty) {
        completer.complete();
        return;
      }
      final blob = html.Blob(_audioBlobs, 'audio/webm;codecs=opus');
      final blobUrl = html.Url.createObjectUrl(blob);
      if (mounted) setState(() {
                _pendingVoiceBlobUrl = blobUrl;
      });
      completer.complete();
    });

    recorder.stop();
    await completer.future;

    if (mounted) setState(() {
      _isRecording = false;
      _audioBlobs.clear();
    });
  }

  Future<void> _cancelRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    if (_mediaRecorder != null) {
      final s = _mediaStream;
      _mediaRecorder!.addEventListener('stop', (_) => s?.getTracks().forEach((t) => t.stop()));
      try { _mediaRecorder!.stop(); } catch (_) {}
      _mediaStream = null;
      _mediaRecorder = null;
    }
    if (_pendingVoiceBlobUrl != null) {
      html.Url.revokeObjectUrl(_pendingVoiceBlobUrl!);
    }
    if (mounted) setState(() {
      _isRecording = false;
      _pendingVoiceBlobUrl = null;
      _audioBlobs.clear();
      _recordingSeconds = 0;
    });
  }

  // Read a blob URL as bytes using XHR (reliable on Flutter Web)
  Future<Uint8List> _fetchBlobBytes(String blobUrl) {
    final completer = Completer<Uint8List>();
    final xhr = html.HttpRequest()
      ..open('GET', blobUrl, async: true)
      ..responseType = 'arraybuffer';
    xhr.onLoad.listen((_) {
      try {
        completer.complete((xhr.response as ByteBuffer).asUint8List());
      } catch (e) { completer.completeError(e); }
    });
    xhr.onError.listen((e) => completer.completeError(e));
    xhr.send();
    return completer.future;
  }

  Future<void> _sendVoiceNote() async {
    if (_pendingVoiceBlobUrl == null || _isUploadingVoice) return;
    final blobUrl = _pendingVoiceBlobUrl!;
    setState(() => _isUploadingVoice = true);
    try {
      final bytes = await _fetchBlobBytes(blobUrl);
      final path = 'voice/${DateTime.now().millisecondsSinceEpoch}.webm';
      await Supabase.instance.client.storage.from('churchStorage').uploadBinary(
        path, bytes,
        fileOptions: const FileOptions(
          contentType: 'audio/webm;codecs=opus',
          cacheControl: '3600',
          upsert: false,
        ),
      );
      final publicUrl = Supabase.instance.client.storage
          .from('churchStorage').getPublicUrl(path);
      if (!mounted) return;
      html.Url.revokeObjectUrl(blobUrl);
      setState(() { _pendingVoiceBlobUrl = null; _recordingSeconds = 0; });
      await _sendMessage(imageUrl: publicUrl, mediaType: 'voice', message: '');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send voice note: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploadingVoice = false);
    }
  }

  // ── Core send (shared by text/image and voice paths) ──────────────────────
  Future<void> _sendMessage({
    String message = '',
    String imageUrl = '',
    String mediaType = 'text',
  }) async {
    await ChatService.sendMessage(
      uniqueId: currentUser?.uniqueChurchId ?? '',
      message: message,
      sender: currentUser?.userName ?? '',
      senderId: currentUser?.phoneNumber ?? '',
      time: DateTime.now().toIso8601String(),
      church: currentUser?.church ?? '',
      imageUrl: imageUrl,
      mediaType: mediaType,
    );
  }

  Future<void> deleteMessage({id, uniqueId}) async {
    await ChatService.deleteMessage(id: id, uniqueId: uniqueId);
  }

  // ── Text/image send ────────────────────────────────────────────────────────
  Future<void> _doSend() async {
    if (_isUploading) return;
    final hasText = messagex.trim().isNotEmpty;
    final hasImage = (_pendingImageUrl ?? '').isNotEmpty ||
        (_pendingImageBytes != null && !_isUploading);
    if (!hasText && !hasImage) return;

    final toSend = messagex.trim();
    final imageUrl = _pendingImageUrl ?? '';
    controller.clear();
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      messagex = '';
      _pendingImageUrl = null;
      _pendingImageBytes = null;
    });

    await _sendMessage(
      message: toSend,
      imageUrl: imageUrl,
      mediaType: imageUrl.isNotEmpty ? 'image' : 'text',
    );

    PushNotifications.sendMessageToTopic(
      topic: PushNotifications.buildTopic(currentUser?.uniqueChurchId ?? '', 'chat'),
      title: currentUser?.userName ?? '',
      body: toSend,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) scrollController.jumpTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = Provider.of<christProvider>(context, listen: false)
            .myMap['Project']?['Expire'] ??
        false;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                AnimatedOpacity(
                  opacity: _isLoadingMore ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Center(child: ConnectLoader(size: 24)),
                ),
                Expanded(child: _buildMessageList()),
                _ChatInputBar(
              controller: controller,
              hasText: messagex.trim().isNotEmpty || _pendingImageBytes != null,
              onChanged: (v) => setState(() => messagex = v),
              onSend: _doSend,
              isVisible: isExpired,
              // Image
              onImagePick: _pickAndUploadImage,
              pendingImageBytes: _pendingImageBytes,
              pendingImageUrl: _pendingImageUrl,
              isUploading: _isUploading,
              onRemoveImage: () => setState(() {
                _pendingImageBytes = null;
                _pendingImageUrl = null;
              }),
              // Voice
              isRecording: _isRecording,
              recordingSeconds: _recordingSeconds,
              pendingVoiceBlobUrl: _pendingVoiceBlobUrl,
              isUploadingVoice: _isUploadingVoice,
              onStartRecord: _startRecording,
              onStopRecord: _stopRecording,
              onCancelRecord: _cancelRecording,
              onSendVoice: _sendVoiceNote,
            ),
          ],
        ),

            // ── Jump-to-message loading overlay ───────────────────────
            if (_isJumpingToMessage)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConnectLoader(size: 32),
                          const SizedBox(height: 12),
                          Text(
                            'Loading message…',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    if (isLoading) return const Center(child: ConnectLoader());
    if (_messages.isEmpty) {
      return Center(
        child: Text('No messages yet.\nSay hello!',
            textAlign: TextAlign.center, style: AppTypography.bodyText),
      );
    }

    final itemCount = _messages.length + 1;
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          if (!_hasMore) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Center(
                child: Text('— start of conversation —',
                    style: AppTypography.caption.copyWith(fontSize: 10)),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        final msg = _messages[_messages.length - 1 - index];
        final isSender = (msg.phoneNumber ?? '') == (currentUser?.phoneNumber ?? '');
        final msgId = msg.id ?? '';
        final msgKey = _messageKeys.putIfAbsent(msgId, () => GlobalKey());
        final isHighlighted = _highlightedMessageId == msgId;

        DateTime? dateTime;
        try { dateTime = DateTime.parse(msg.time ?? ''); } catch (_) {}
        final timeLabel = dateTime != null
            ? '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}'
            : '';

        final bubble = isSender
            ? MessageBubbleRight(
                key: ValueKey(msg.id),
                text: msg.message ?? '',
                name: timeLabel,
                image: msg.profileImage ?? '',
                imageUrl: msg.imageUrl ?? '',
                mediaType: msg.mediaType ?? 'text',
                callBack: () => alertDeleteMessage(
                  context, 'Delete this message?',
                  () async => deleteMessage(id: msg.id ?? '', uniqueId: msg.uniqueChurchId ?? ''),
                ),
              )
            : MessageBubbleLeft(
                key: ValueKey(msg.id),
                text: msg.message ?? '',
                name: timeLabel,
                image: msg.profileImage ?? '',
                imageUrl: msg.imageUrl ?? '',
                mediaType: msg.mediaType ?? 'text',
                person: msg.sender ?? '',
                callBack: () => alertDeleteMessage(
                  context, 'Delete this message?',
                  () async => deleteMessage(id: msg.id ?? '', uniqueId: msg.uniqueChurchId ?? ''),
                ),
              );

        return AnimatedContainer(
          key: msgKey,
          duration: const Duration(milliseconds: 300),
          color: isHighlighted
              ? AppColors.purple.withValues(alpha: 0.15)
              : Colors.transparent,
          child: bubble,
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
  final bool hasText;
  // Image
  final VoidCallback? onImagePick;
  final Uint8List? pendingImageBytes;
  final String? pendingImageUrl;
  final bool isUploading;
  final VoidCallback? onRemoveImage;
  // Voice
  final bool isRecording;
  final int recordingSeconds;
  final String? pendingVoiceBlobUrl;
  final bool isUploadingVoice;
  final VoidCallback? onStartRecord;
  final VoidCallback? onStopRecord;
  final VoidCallback? onCancelRecord;
  final VoidCallback? onSendVoice;

  const _ChatInputBar({
    required this.controller,
    required this.onChanged,
    required this.onSend,
    required this.isVisible,
    this.hasText = false,
    this.onImagePick,
    this.pendingImageBytes,
    this.pendingImageUrl,
    this.isUploading = false,
    this.onRemoveImage,
    this.isRecording = false,
    this.recordingSeconds = 0,
    this.pendingVoiceBlobUrl,
    this.isUploadingVoice = false,
    this.onStartRecord,
    this.onStopRecord,
    this.onCancelRecord,
    this.onSendVoice,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    // ── Recording in progress ──────────────────────────────────────────────
    if (isRecording) return _RecordingBar(
      seconds: recordingSeconds,
      onStop: onStopRecord ?? () {},
      onCancel: onCancelRecord ?? () {},
    );

    // ── Voice note preview (listen before sending) ─────────────────────────
    if (pendingVoiceBlobUrl != null) return _VoicePreviewInputBar(
      blobUrl: pendingVoiceBlobUrl!,
      isUploading: isUploadingVoice,
      onSend: onSendVoice ?? () {},
      onCancel: onCancelRecord ?? () {},
    );

    // ── Normal text / image input ──────────────────────────────────────────
    final hasPendingImage = pendingImageBytes != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.surfaceAlt, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pending image preview
          if (hasPendingImage)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(pendingImageBytes!, fit: BoxFit.cover),
                      ),
                      if (isUploading)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            color: Colors.black38,
                            child: const Center(
                              child: SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      if (!isUploading)
                        Positioned(
                          top: 4, right: 4,
                          child: GestureDetector(
                            onTap: onRemoveImage,
                            child: Container(
                              width: 20, height: 20,
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // Input row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image button
                GestureDetector(
                  onTap: isUploading ? null : onImagePick,
                  child: Container(
                    width: 36, height: 36,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: hasPendingImage ? AppColors.purpleTint : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surfaceAlt, width: 1.5),
                    ),
                    child: Icon(Icons.image_outlined, size: 18,
                        color: hasPendingImage ? AppColors.purple : AppColors.textMuted),
                  ),
                ),

                // Mic button
                GestureDetector(
                  onTap: onStartRecord,
                  child: Container(
                    width: 36, height: 36,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surfaceAlt, width: 1.5),
                    ),
                    child: Icon(Icons.mic_none_rounded, size: 18, color: AppColors.textMuted),
                  ),
                ),

                // Text field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                      border: Border.all(color: AppColors.surfaceAlt, width: 1.5),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                AnimatedOpacity(
                  opacity: hasText ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTap: hasText ? onSend : null,
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.purple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recording Bar ────────────────────────────────────────────────────────────
class _RecordingBar extends StatelessWidget {
  final int seconds;
  final VoidCallback onStop;
  final VoidCallback onCancel;

  const _RecordingBar({required this.seconds, required this.onStop, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.surfaceAlt, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Cancel
          GestureDetector(
            onTap: onCancel,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.surfaceAlt, width: 1.5),
              ),
              child: Icon(Icons.close, size: 18, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(width: 12),

          // Pulsing indicator + timer
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200, width: 1),
              ),
              child: Row(
                children: [
                  _PulseDot(),
                  const SizedBox(width: 8),
                  Text(
                    'Recording  $mm:$ss',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.red.shade700, fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '/ 00:30',
                    style: AppTypography.caption.copyWith(color: Colors.red.shade400),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Stop button
          GestureDetector(
            onTap: onStop,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.stop_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Voice Preview Input Bar (listen before sending) ─────────────────────────
class _VoicePreviewInputBar extends StatelessWidget {
  final String blobUrl;
  final bool isUploading;
  final VoidCallback onSend;
  final VoidCallback onCancel;

  const _VoicePreviewInputBar({
    required this.blobUrl,
    required this.isUploading,
    required this.onSend,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.surfaceAlt, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Cancel
          GestureDetector(
            onTap: onCancel,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.surfaceAlt, width: 1.5),
              ),
              child: Icon(Icons.close, size: 18, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(width: 10),

          // Preview player
          Expanded(child: _VoicePlayer(url: blobUrl)),

          const SizedBox(width: 10),

          // Send / uploading
          isUploading
              ? const SizedBox(
                  width: 44, height: 44,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : GestureDetector(
                  onTap: onSend,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.purple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
        ],
      ),
    );
  }
}

// ─── Web audio player — uses dart:html AudioElement directly ─────────────────
// Works for both blob URLs (preview) and HTTPS URLs (sent messages).
class _VoicePlayer extends StatefulWidget {
  final String url;
  final bool isOwn;

  const _VoicePlayer({required this.url, this.isOwn = false});

  @override
  State<_VoicePlayer> createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<_VoicePlayer> {
  html.AudioElement? _audio;
  bool _isPlaying = false;
  double _progress = 0.0;
  String _durationLabel = '…';
  final List<StreamSubscription> _subs = [];

  @override
  void initState() {
    super.initState();
    final audio = html.AudioElement()..src = widget.url;
    _audio = audio;

    _subs.add(audio.onDurationChange.listen((_) {
      final d = audio.duration;
      if (mounted && d.isFinite && !d.isNaN) {
        setState(() => _durationLabel = _fmt(d));
      }
    }));
    _subs.add(audio.onTimeUpdate.listen((_) {
      final d = audio.duration;
      if (mounted && d.isFinite && d > 0) {
        setState(() => _progress = (audio.currentTime / d).clamp(0.0, 1.0));
      }
    }));
    _subs.add(audio.onEnded.listen((_) {
      if (mounted) setState(() { _isPlaying = false; _progress = 0; });
    }));
    _subs.add(audio.onPlay.listen((_) { if (mounted) setState(() => _isPlaying = true); }));
    _subs.add(audio.onPause.listen((_) { if (mounted) setState(() => _isPlaying = false); }));
  }

  @override
  void didUpdateWidget(_VoicePlayer old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      _audio?.pause();
      _audio?.src = widget.url;
      setState(() { _isPlaying = false; _progress = 0; _durationLabel = '…'; });
    }
  }

  @override
  void dispose() {
    for (final s in _subs) s.cancel();
    _audio?.pause();
    _audio?.src = '';
    _audio = null;
    super.dispose();
  }

  String _fmt(num seconds) {
    final s = seconds.isFinite ? seconds.round() : 0;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _togglePlay() async {
    final audio = _audio;
    if (audio == null) return;
    if (_isPlaying) {
      audio.pause();
    } else {
      try { await audio.play(); } catch (e) { debugPrint('[Audio] play error: $e'); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg     = widget.isOwn ? Colors.white24      : AppColors.purpleTint;
    final icon   = widget.isOwn ? Colors.white        : AppColors.purple;
    final active = widget.isOwn ? Colors.white        : AppColors.purple;
    final track  = widget.isOwn ? Colors.white30      : AppColors.surfaceAlt;
    final label  = widget.isOwn ? Colors.white70      : AppColors.textMuted;

    return Row(
      children: [
        GestureDetector(
          onTap: _togglePlay,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: icon, size: 20),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SliderTheme(
                data: SliderThemeData(
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                  trackHeight: 2.5,
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                ),
                child: SizedBox(
                  height: 20,
                  child: Slider(
                    value: _progress,
                    onChanged: (v) {
                      final audio = _audio;
                      if (audio == null || !audio.duration.isFinite) return;
                      audio.currentTime = v * audio.duration;
                      setState(() => _progress = v);
                    },
                    activeColor: active,
                    inactiveColor: track,
                  ),
                ),
              ),
              Text(_durationLabel,
                  style: TextStyle(fontSize: 10, color: label, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Pulsing red dot for recording indicator ──────────────────────────────────
class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.35, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 10, height: 10,
        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
      ),
    );
  }
}

// ─── Message Bubble — Other User (Left) ──────────────────────────────────────
class MessageBubbleLeft extends StatelessWidget {
  final String? text;
  final String? name;
  final String? image;
  final String? imageUrl;
  final String? mediaType;
  final String? person;
  final VoidCallback? callBack;

  const MessageBubbleLeft({
    this.text,
    this.image,
    this.imageUrl,
    this.mediaType,
    this.name,
    this.person,
    this.callBack,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isVoice = (mediaType ?? '') == 'voice';
    final hasImage = !isVoice && (imageUrl ?? '').isNotEmpty;
    final hasText = (text ?? '').isNotEmpty;

    return GestureDetector(
      onLongPress: callBack ?? () {},
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ConnectAvatar(
              name: person ?? 'U',
              imageUrl: (image != null && image!.isNotEmpty) ? image : null,
              size: AvatarSize.xs,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (person != null && person!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(person!,
                        style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                  ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.62),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                    child: isVoice
                        ? _VoiceNoteBubble(url: imageUrl ?? '', isOwn: false)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasImage)
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(hasText ? 0 : 4),
                                    bottomRight: Radius.circular(hasText ? 0 : 16),
                                  ),
                                  child: Image.network(
                                    imageUrl!,
                                    width: MediaQuery.of(context).size.width * 0.62,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: MediaQuery.of(context).size.width * 0.62,
                                      height: 120,
                                      color: AppColors.surfaceAlt,
                                      child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
                                    ),
                                  ),
                                ),
                              if (hasText)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  child: Text(text!,
                                      style: AppTypography.bodyMedium.copyWith(height: 1.45)),
                                ),
                            ],
                          ),
                  ),
                ),
                if (name != null && name!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: Text(name!, style: AppTypography.caption.copyWith(fontSize: 10)),
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
  final String? imageUrl;
  final String? mediaType;
  final VoidCallback? callBack;

  const MessageBubbleRight({
    this.text,
    this.name,
    this.image,
    this.imageUrl,
    this.mediaType,
    this.callBack,
    super.key,
  });

  @override
  State<MessageBubbleRight> createState() => _MessageBubbleRightState();
}

class _MessageBubbleRightState extends State<MessageBubbleRight> {
  @override
  Widget build(BuildContext context) {
    final isVoice = (widget.mediaType ?? '') == 'voice';
    final hasImage = !isVoice && (widget.imageUrl ?? '').isNotEmpty;
    final hasText = (widget.text ?? '').isNotEmpty;

    return GestureDetector(
      onLongPress: widget.callBack ?? () {},
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.62),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isVoice ? null : AppColors.purpleCardGradient,
                      color: isVoice ? AppColors.purple : null,
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
                    child: isVoice
                        ? _VoiceNoteBubble(url: widget.imageUrl ?? '', isOwn: true)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasImage)
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomRight: Radius.circular(hasText ? 0 : 4),
                                    bottomLeft: Radius.circular(hasText ? 0 : 16),
                                  ),
                                  child: Image.network(
                                    widget.imageUrl!,
                                    width: MediaQuery.of(context).size.width * 0.62,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: MediaQuery.of(context).size.width * 0.62,
                                      height: 120,
                                      color: Colors.white12,
                                      child: const Icon(Icons.broken_image_outlined, color: Colors.white38),
                                    ),
                                  ),
                                ),
                              if (hasText)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  child: Text(widget.text!,
                                      style: AppTypography.bodyMedium.copyWith(
                                          color: AppColors.white, height: 1.45)),
                                ),
                            ],
                          ),
                  ),
                ),
                if (widget.name != null && widget.name!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 4, top: 4),
                    child: Text(widget.name!, style: AppTypography.caption.copyWith(fontSize: 10)),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            ConnectAvatar(
              name: 'Me',
              imageUrl: (widget.image != null && widget.image!.isNotEmpty) ? widget.image : null,
              size: AvatarSize.xs,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Voice Note Bubble — wraps _VoicePlayer with bubble padding ──────────────
class _VoiceNoteBubble extends StatelessWidget {
  final String url;
  final bool isOwn;

  const _VoiceNoteBubble({required this.url, this.isOwn = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: SizedBox(
        width: 200,
        child: _VoicePlayer(url: url, isOwn: isOwn),
      ),
    );
  }
}
