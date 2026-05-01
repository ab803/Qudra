import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/Models/ChatMessage.dart';
import '../../../core/Services/Localization/ar.dart';
import '../../../core/Services/Localization/en.dart';
import '../../../core/Utilies/getit.dart';
import '../AIRepo/AIRepo.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final IChatRepository _repository;

  // This key reuses the same saved language preference used by the app language cubit.
  static const String _languageKey = 'app_language';

  ChatCubit()
      : _repository = getIt<IChatRepository>(),
        super(ChatInitial()) {
    _init();
  }

  // ── Boot with a welcome message ──────────────────────────────
  Future<void> _init() async {
    // This resolves the localized welcome message before emitting the initial chat state.
    final welcomeMessage = await _translate('chat_welcome_message');

    emit(ChatLoaded(
      messages: [
        ChatMessage(
          text: welcomeMessage,
          isUser: false,
          time: DateTime.now(),
        ),
      ],
    ));
  }

  // This helper returns the localized value for a given key based on the saved language or system locale.
  Future<String> _translate(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_languageKey);

    final localeCode = (savedCode == null || savedCode == 'system')
        ? WidgetsBinding.instance.platformDispatcher.locale.languageCode
        : savedCode;

    final values = localeCode == 'ar' ? ar : en;
    return values[key] ?? key;
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