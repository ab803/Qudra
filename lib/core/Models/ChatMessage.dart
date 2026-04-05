class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final bool isTyping; // true = show typing indicator

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.isTyping = false,
  });

  // Typing indicator placeholder
  factory ChatMessage.typing() => ChatMessage(
    text: '',
    isUser: false,
    time: DateTime.now(),
    isTyping: true,
  );
}