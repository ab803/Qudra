import '../../../core/Models/ChatMessage.dart';


abstract class IChatRepository {
  /// Send a message and get AI reply
  Future<ChatMessage> sendMessage(String text);

  /// Send a suggestion pill message
  Future<ChatMessage> sendSuggestion(String suggestion);

  /// Reset conversation history
  void resetChat();
}