import '../../../core/Models/ChatMessage.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

// ✅ Main state — always holds the full messages list
class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isTyping; // true while waiting for Gemini response

  ChatLoaded({
    required this.messages,
    this.isTyping = false,
  });

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatFailure extends ChatState {
  final String errorMessage;
  ChatFailure({required this.errorMessage});
}