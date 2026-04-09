import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';
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
  final _textController   = TextEditingController();

  static const _suggestions = [
    ('Emergency help',       Icons.emergency_outlined, true),
    ('Nearby institutions',  Icons.place_outlined,     false),
    ('Accessible transport', Icons.directions_bus_outlined, false),
    ('My rights',            Icons.gavel_outlined,     false),
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
    return Scaffold(
      backgroundColor: Appcolors.backgroundColor,
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
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(state.errorMessage),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                },
                builder: (context, state) {
                  if (state is ChatLoaded) {
                    return _buildMessageList(state.messages, state.isTyping);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),

            // ── Suggestion pills ───────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final (label, icon, isCritical) in _suggestions) ...[
                      ChatSuggestionPill(
                        label: label,
                        icon: icon,
                        isCritical: isCritical,
                        onTap: () => _onSuggestion(label), // ✅ wired
                      ),
                      const SizedBox(width: 10),
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

  Widget _buildMessageList(List<ChatMessage> messages, bool isTyping) {
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
            time: _formatTime(DateTime.now()),
          );
        }
        final msg = messages[i];
        return ChatMessageTile(
          isUser: msg.isUser,
          name: msg.isUser ? 'You' : 'Qudra AI',
          time: _formatTime(msg.time),
          text: msg.text,
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Appcolors.primaryColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Qudra AI',
            style: AppTextStyles.subtitle.copyWith(
              color: Appcolors.primaryColor,
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
                  color: Appcolors.successColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'ONLINE',
                style: AppTextStyles.body.copyWith(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: Appcolors.secondaryColor,
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
          icon: const Icon(Icons.refresh, color: Appcolors.primaryColor),
          tooltip: 'Clear chat',
          onPressed: () => context.read<ChatCubit>().clearChat(),
        ),
        IconButton(
          icon: const Icon(Icons.info_outline, color: Appcolors.primaryColor),
          onPressed: () {},
        ),
      ],
    );
  }
}