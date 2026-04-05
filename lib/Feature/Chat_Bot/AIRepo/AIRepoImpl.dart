import '../../../core/Models/ChatMessage.dart';
import '../../../core/Services/Gemini/GeminiService.dart';
import 'AIRepo.dart';


class ChatRepositoryImpl implements IChatRepository {
  final GeminiService _service;

  ChatRepositoryImpl({required GeminiService service})
      : _service = service;

  // ─────────────────────────────────────────
  // SEND MESSAGE
  // ─────────────────────────────────────────
  @override
  Future<ChatMessage> sendMessage(String text) async {
    final reply = await _service.sendMessage(text);
    return ChatMessage(
      text: reply,
      isUser: false,
      time: DateTime.now(),
    );
  }

  // ─────────────────────────────────────────
  // SEND SUGGESTION
  // ─────────────────────────────────────────
  @override
  Future<ChatMessage> sendSuggestion(String suggestion) =>
      sendMessage(suggestion);

  // ─────────────────────────────────────────
  // RESET CHAT
  // ─────────────────────────────────────────
  @override
  void resetChat() => _service.resetChat();
}