import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/Models/ChatMessage.dart';
import '../../../core/Utilies/getit.dart';
import '../AIRepo/AIRepo.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final IChatRepository _repository;

  ChatCubit()
      : _repository = getIt<IChatRepository>(),
        super(ChatInitial()) {
    _init();
  }

  // ── Boot with a welcome message ──────────────────────────────
  void _init() {
    emit(ChatLoaded(
      messages: [
        ChatMessage(
          text: 'Hi! I\'m Qudra AI. How can I help you today?',
          isUser: false,
          time: DateTime.now(),
        ),
      ],
    ));
  }

  // ── Send message ─────────────────────────────────────────────
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final current = state is ChatLoaded
        ? (state as ChatLoaded).messages
        : <ChatMessage>[];

    final withUser = [
      ...current,
      ChatMessage(text: trimmed, isUser: true, time: DateTime.now()),
    ];
    emit(ChatLoaded(messages: withUser, isTyping: true));

    try {
      final reply = await _repository.sendMessage(trimmed);
      emit(ChatLoaded(messages: [...withUser, reply], isTyping: false));
    } catch (e) {
      emit(ChatLoaded(messages: withUser, isTyping: false));
      emit(ChatFailure(errorMessage: e.toString()));
    }
  }

  // ── Send suggestion ──────────────────────────────────────────
  Future<void> sendSuggestion(String suggestion) =>
      sendMessage(suggestion);

  // ── Clear chat ───────────────────────────────────────────────
  void clearChat() {
    _repository.resetChat();
    _init();
  }
}