import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// This import enables localized text access using context.tr().
import '../../../core/Services/Localization/translation_extension.dart';
import '../../../core/Models/ChatMessage.dart';
import '../view model/chat_cubit.dart';
import '../view model/chat_state.dart';
import '../widgets/chat_message_tile.dart';
import '../widgets/chat_typing_indicator.dart';
import '../widgets/chat_suggestion_pill.dart';
import '../widgets/chat_input_bar.dart';

class ChatBotView extends StatelessWidget {
  const ChatBotView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatCubit(),
      child: const _ChatBotBody(),
    );
  }
}

class _ChatBotBody extends StatefulWidget {
  const _ChatBotBody();

  @override
  State<_ChatBotBody> createState() => _ChatBotBodyState();
}

class _ChatBotBodyState extends State<_ChatBotBody> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();

  // This list stores localization keys for the suggestion pills.
  static const _suggestions = [
    ('emergency_help', Icons.emergency_outlined, true),
    ('nearby_institutions', Icons.place_outlined, false),
    ('accessible_transport', Icons.directions_bus_outlined, false),
    ('my_rights', Icons.gavel_outlined, false),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    context.read<ChatCubit>().sendMessage(text);
    _scrollToBottom();
  }

  void _onSuggestion(String label) {
    context.read<ChatCubit>().sendSuggestion(label);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            // ── Messages ───────────────────────────────────────
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  if (state is ChatLoaded) _scrollToBottom();

                  if (state is ChatFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.errorMessage,
                          style: TextStyle(color: colorScheme.onError),
                        ),
                        backgroundColor: colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ChatLoaded) {
                    return _buildMessageList(context, state.messages, state.isTyping);
                  }

                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  );
                },
              ),
            ),

            // ── Suggestion pills ───────────────────────────────
            Container(
              color: theme.cardColor,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final (key, icon, isCritical) in _suggestions) ...[
                      // This resolves the localized suggestion label from its key.
                      Builder(
                        builder: (context) {
                          final label = context.tr(key);
                          return Row(
                            children: [
                              ChatSuggestionPill(
                                label: label,
                                icon: icon,
                                isCritical: isCritical,
                                onTap: () => _onSuggestion(label), // ✅ wired
                              ),
                              const SizedBox(width: 10),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Input bar ──────────────────────────────────────
            ChatInputBar(
              controller: _textController,
              onSend: _onSend,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(
      BuildContext context,
      List<ChatMessage> messages,
      bool isTyping,
      ) {
    final itemCount = messages.length + (isTyping ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) {
        // Last item = typing indicator
        if (isTyping && i == itemCount - 1) {
          return ChatTypingIndicator(
            // This formats time using the active locale.
            time: _formatTime(context, DateTime.now()),
          );
        }

        final msg = messages[i];
        return ChatMessageTile(
          isUser: msg.isUser,
          // This sender name is localized for user and AI messages.
          name: msg.isUser ? context.tr('you') : context.tr('ai_name'),
          // This formats message time using the active locale.
          time: _formatTime(context, msg.time),
          text: msg.text,
        );
      },
    );
  }

  // This formats the time using Flutter's localized MaterialLocalizations.
  String _formatTime(BuildContext context, DateTime dt) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(dt),
      alwaysUse24HourFormat: false,
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: colorScheme.primary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            // This app bar title is localized for the AI assistant name.
            context.tr('ai_name'),
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                // This status label is localized.
                context.tr('online'),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface.withOpacity(0.65),
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // ✅ Clear chat button
        IconButton(
          icon: Icon(Icons.refresh, color: colorScheme.primary),
          // This tooltip is localized for clearing the chat.
          tooltip: context.tr('clear_chat'),
          onPressed: () => context.read<ChatCubit>().clearChat(),
        ),
        IconButton(
          icon: Icon(Icons.info_outline, color: colorScheme.primary),
          onPressed: () {},
        ),
      ],
    );
  }
}