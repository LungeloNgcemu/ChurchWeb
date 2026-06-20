import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:master/services/api/chat_service.dart';
import 'package:master/services/api/token_service.dart';
import 'package:master/theme/app_colors.dart';
import 'package:master/theme/app_spacing.dart';
import 'package:master/theme/app_typography.dart';
import 'package:master/theme/theme_manager.dart';
import 'package:master/widgets/common/connect_avatar.dart';
import '../screens/chat/message_screen.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _searchLoading = false;
  Timer? _debounce;
  String _uniqueChurchId = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await TokenService.tokenUser();
    if (user != null && mounted) {
      setState(() => _uniqueChurchId = user.uniqueChurchId ?? '');
    }
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 380), () => _doSearch(q.trim()));
  }

  Future<void> _doSearch(String q) async {
    if (q.isEmpty) {
      setState(() { _searchResults = []; _searchLoading = false; });
      return;
    }
    setState(() => _searchLoading = true);
    try {
      final results = await ChatService.searchMessages(
        uniqueId: _uniqueChurchId, query: q);
      if (mounted) setState(() { _searchResults = results; _searchLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _searchLoading = false);
    }
  }

  void _closeSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() { _isSearching = false; _searchResults = []; _searchLoading = false; });
  }

  void _jumpToMessage(int msgId) {
    _closeSearch();
    // Give the search overlay a frame to close before scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MessageScreen.scrollToMessageId?.call(msgId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topBarH = AppSpacing.topBarHeight + MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Column(
            children: [
              // ── Topbar ───────────────────────────────────────────────────
              _isSearching
                  ? _SearchTopBar(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onClose: _closeSearch,
                    )
                  : _ChatTopBar(
                      onSearchTap: () => setState(() => _isSearching = true),
                    ),

              // ── Chat ─────────────────────────────────────────────────────
              const Expanded(child: MessageScreen()),
            ],
          ),

          // ── Search results overlay ────────────────────────────────────
          if (_isSearching)
            Positioned(
              top: topBarH,
              left: 0, right: 0, bottom: 0,
              child: _SearchResultsPanel(
                results: _searchResults,
                isLoading: _searchLoading,
                query: _searchController.text,
                onTap: _jumpToMessage,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Normal topbar ─────────────────────────────────────────────────────────────

class _ChatTopBar extends StatelessWidget {
  final VoidCallback onSearchTap;
  const _ChatTopBar({required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>();
    return Container(
      height: AppSpacing.topBarHeight + MediaQuery.of(context).padding.top,
      color: AppColors.navy,
      padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top, 18, 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Chat', style: AppTypography.screenTitle.copyWith(fontSize: 20)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('•',
                      style: AppTypography.labelTiny.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 10)),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: AppColors.navyIconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.search_rounded, size: 18, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search topbar ─────────────────────────────────────────────────────────────

class _SearchTopBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;
  const _SearchTopBar({
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.topBarHeight + MediaQuery.of(context).padding.top,
      color: AppColors.navy,
      padding: EdgeInsets.fromLTRB(12, MediaQuery.of(context).padding.top, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: AppColors.navyIconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.navyIconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: controller,
                autofocus: true,
                style: AppTypography.bodyText.copyWith(
                    color: AppColors.white, fontSize: 14),
                cursorColor: AppColors.purple,
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  hintStyle: AppTypography.bodyText.copyWith(
                      color: AppColors.whiteDim, fontSize: 14),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search results panel ──────────────────────────────────────────────────────

class _SearchResultsPanel extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final bool isLoading;
  final String query;
  final void Function(int msgId) onTap;

  const _SearchResultsPanel({
    required this.results,
    required this.isLoading,
    required this.query,
    required this.onTap,
  });

  String _timeLabel(dynamic raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      }
      return DateFormat('d MMM').format(dt);
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeManager>().colors;

    return Container(
      color: colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header count / loading
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
            child: isLoading
                ? Row(children: [
                    const SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.purple),
                    ),
                    const SizedBox(width: 8),
                    Text('Searching…',
                        style: AppTypography.caption.copyWith(
                            color: colors.textMuted, fontSize: 12)),
                  ])
                : Text(
                    query.isEmpty
                        ? 'Type to search'
                        : results.isEmpty
                            ? 'No messages found for "$query"'
                            : '${results.length} result${results.length == 1 ? '' : 's'} for "$query"',
                    style: AppTypography.caption.copyWith(
                        color: colors.textMuted, fontSize: 12),
                  ),
          ),
          Divider(height: 1, color: colors.backgroundAlt),

          if (results.isNotEmpty)
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: results.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, indent: 66, color: colors.backgroundAlt),
                itemBuilder: (context, i) {
                  final r = results[i];
                  final msgId = r['id'] as int? ?? 0;
                  final sender = (r['Sender'] as String?) ?? 'Member';
                  final message = (r['Message'] as String?) ?? '';
                  final image = r['ProfileImage'] as String?;
                  final time = _timeLabel(r['created_at']);

                  return InkWell(
                    onTap: () => onTap(msgId),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConnectAvatar(
                            name: sender,
                            imageUrl: image,
                            size: AvatarSize.sm,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        sender,
                                        style: AppTypography.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      time,
                                      style: AppTypography.caption.copyWith(
                                          fontSize: 11,
                                          color: colors.textMuted),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                _HighlightedText(
                                  text: message,
                                  query: query,
                                  baseStyle: AppTypography.bodyText.copyWith(
                                      fontSize: 12, color: colors.textSecondary),
                                  highlightColor: AppColors.purple,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.keyboard_arrow_right_rounded,
                              size: 18, color: AppColors.purple),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          else if (!isLoading && query.isNotEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off_rounded,
                        size: 40,
                        color: colors.primary.withValues(alpha: 0.3)),
                    const SizedBox(height: 10),
                    Text('No messages found',
                        style: AppTypography.bodyText.copyWith(
                            color: colors.textMuted, fontSize: 13)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Highlighted text — bolds the matched query term ──────────────────────────

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle baseStyle;
  final Color highlightColor;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle, maxLines: 2, overflow: TextOverflow.ellipsis);
    }
    final lower = text.toLowerCase();
    final lowerQ = query.toLowerCase();
    final start = lower.indexOf(lowerQ);
    if (start == -1) {
      return Text(text, style: baseStyle, maxLines: 2, overflow: TextOverflow.ellipsis);
    }
    final end = start + query.length;
    return Text.rich(
      TextSpan(children: [
        if (start > 0) TextSpan(text: text.substring(0, start), style: baseStyle),
        TextSpan(
          text: text.substring(start, end),
          style: baseStyle.copyWith(
            color: highlightColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (end < text.length) TextSpan(text: text.substring(end), style: baseStyle),
      ]),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
