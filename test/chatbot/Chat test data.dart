import 'package:qudra_0/core/Models/ChatMessage.dart';

// ---------------------------------------------------------------------------
// ChatMessage factory
// ---------------------------------------------------------------------------

ChatMessage makeUserMessage({
  String text = 'Hello, I need help.',
  DateTime? time,
}) =>
    ChatMessage(
      text: text,
      isUser: true,
      time: time ?? DateTime(2025, 6, 1, 10, 0),
    );

ChatMessage makeBotMessage({
  String text = 'Hi! How can I assist you today?',
  DateTime? time,
}) =>
    ChatMessage(
      text: text,
      isUser: false,
      time: time ?? DateTime(2025, 6, 1, 10, 0, 1),
    );

ChatMessage makeWelcomeMessage({
  String text = 'Welcome to Qudra AI. How can I help you?',
}) =>
    ChatMessage(
      text: text,
      isUser: false,
      time: DateTime(2025, 6, 1, 10, 0),
    );

// ---------------------------------------------------------------------------
// Conversation builders
// ---------------------------------------------------------------------------

/// A two-message conversation: one user, one bot.
List<ChatMessage> makeConversation() => [
  makeUserMessage(),
  makeBotMessage(),
];

/// A longer conversation for scroll/list rendering tests.
List<ChatMessage> makeLongConversation({int length = 10}) => [
  for (var i = 0; i < length; i++)
    i.isEven
        ? makeUserMessage(text: 'User message $i')
        : makeBotMessage(text: 'Bot reply $i'),
];

// ---------------------------------------------------------------------------
// Suggestion labels
// ---------------------------------------------------------------------------

const kTestSuggestions = [
  'Emergency Help',
  'Nearby Institutions',
  'Accessible Transport',
  'My Rights',
];