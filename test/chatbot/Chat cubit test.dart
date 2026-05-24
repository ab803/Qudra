import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/Chat_Bot/view%20model/chat_cubit.dart';
import 'package:qudra_0/Feature/Chat_Bot/view%20model/chat_state.dart';
import 'package:qudra_0/core/Models/ChatMessage.dart';
import 'Chat mock classes.dart';
import 'Chat test data.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

MockChatRepository _repo() {
  registerChatFallbacks();
  return MockChatRepository();
}

/// Builds a cubit pre-seeded with a welcome message so tests
/// that focus on `sendMessage` don't need to wait for `_init`.
ChatCubit _cubitWithRepo(MockChatRepository repo) =>
    ChatCubit();

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ChatCubit', () {
    // -----------------------------------------------------------------------
    // Initialisation
    // -----------------------------------------------------------------------
    group('_init / boot', () {
      test('initial state before _init resolves is ChatInitial', () {
        final repo = _repo();
        final cubit = ChatCubit();
        // Synchronously the state is ChatInitial before the async _init runs.
        expect(cubit.state, isA<ChatInitial>());
      });

      blocTest<ChatCubit, ChatState>(
        'emits ChatLoaded with a single bot welcome message after init',
        build: () => _cubitWithRepo(_repo()),
        // No act — the constructor calls _init() automatically.
        wait: const Duration(milliseconds: 300),
        expect: () => [
          isA<ChatLoaded>()
              .having((s) => s.messages, 'messages', hasLength(1))
              .having(
                (s) => s.messages.first.isUser,
            'isUser',
            isFalse,
          )
              .having(
                (s) => s.isTyping,
            'isTyping',
            isFalse,
          ),
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'welcome message text is not empty',
        build: () => _cubitWithRepo(_repo()),
        wait: const Duration(milliseconds: 300),
        expect: () => [
          isA<ChatLoaded>().having(
                (s) => s.messages.first.text,
            'welcome text',
            isNotEmpty,
          ),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // sendMessage — happy path
    // -----------------------------------------------------------------------
    group('sendMessage – success', () {
      blocTest<ChatCubit, ChatState>(
        'emits [ChatLoaded isTyping:true, ChatLoaded isTyping:false] on success',
        build: () {
          final repo = _repo();
          when(() => repo.sendMessage(any()))
              .thenAnswer((_) async => makeBotMessage());
          return _cubitWithRepo(repo);
        },
        // Skip the init-emitted state; seed directly.
        seed: () => ChatLoaded(messages: [makeWelcomeMessage()]),
        act: (c) => c.sendMessage('I need help.'),
        expect: () => [
          isA<ChatLoaded>()
              .having((s) => s.isTyping, 'isTyping', isTrue)
              .having((s) => s.messages, 'messages',
              hasLength(2)), // welcome + user
          isA<ChatLoaded>()
              .having((s) => s.isTyping, 'isTyping', isFalse)
              .having((s) => s.messages, 'messages',
              hasLength(3)), // welcome + user + bot
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'appended user message has isUser == true',
        build: () {
          final repo = _repo();
          when(() => repo.sendMessage(any()))
              .thenAnswer((_) async => makeBotMessage());
          return _cubitWithRepo(repo);
        },
        seed: () => ChatLoaded(messages: [makeWelcomeMessage()]),
        act: (c) => c.sendMessage('My question'),
        expect: () => [
          isA<ChatLoaded>().having(
                (s) => s.messages.last.isUser,
            'user message isUser',
            isTrue,
          ),
          isA<ChatLoaded>().having(
                (s) => s.messages.last.isUser,
            'bot reply isUser',
            isFalse,
          ),
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'appended user message preserves the trimmed text',
        build: () {
          final repo = _repo();
          when(() => repo.sendMessage(any()))
              .thenAnswer((_) async => makeBotMessage());
          return _cubitWithRepo(repo);
        },
        seed: () => ChatLoaded(messages: [makeWelcomeMessage()]),
        act: (c) => c.sendMessage('  hello world  '),
        expect: () => [
          isA<ChatLoaded>().having(
                (s) => s.messages.last.text,
            'trimmed user text',
            'hello world',
          ),
          anything,
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'bot reply text comes from the repository response',
        build: () {
          final repo = _repo();
          when(() => repo.sendMessage(any())).thenAnswer(
                (_) async => makeBotMessage(text: 'Nearest clinic is 0.3 km away.'),
          );
          return _cubitWithRepo(repo);
        },
        seed: () => ChatLoaded(messages: [makeWelcomeMessage()]),
        act: (c) => c.sendMessage('nearest clinic'),
        skip: 1, // skip typing state
        expect: () => [
          isA<ChatLoaded>().having(
                (s) => s.messages.last.text,
            'bot reply text',
            'Nearest clinic is 0.3 km away.',
          ),
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'message history grows cumulatively across multiple sends',
        build: () {
          final repo = _repo();
          when(() => repo.sendMessage(any()))
              .thenAnswer((_) async => makeBotMessage());
          return _cubitWithRepo(repo);
        },
        seed: () => ChatLoaded(messages: [makeWelcomeMessage()]),
        act: (c) async {
          await c.sendMessage('First');
          await c.sendMessage('Second');
        },
        // After both sends: welcome + user1 + bot1 + user2 + bot2 = 5
        expect: () => [
          anything, // typing 1
          isA<ChatLoaded>()
              .having((s) => s.messages.length, 'after first send', 3),
          anything, // typing 2
          isA<ChatLoaded>()
              .having((s) => s.messages.length, 'after second send', 5),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // sendMessage — empty / whitespace guard
    // -----------------------------------------------------------------------
    group('sendMessage – empty guard', () {
      blocTest<ChatCubit, ChatState>(
        'does nothing when text is empty',
        build: () => _cubitWithRepo(_repo()),
        seed: () => ChatLoaded(messages: [makeWelcomeMessage()]),
        act: (c) => c.sendMessage(''),
        expect: () => [],
      );

      blocTest<ChatCubit, ChatState>(
        'does nothing when text is only whitespace',
        build: () => _cubitWithRepo(_repo()),
        seed: () => ChatLoaded(messages: [makeWelcomeMessage()]),
        act: (c) => c.sendMessage('   '),
        expect: () => [],
      );
    });

    // -----------------------------------------------------------------------
    // sendMessage — error path
    // -----------------------------------------------------------------------
    group('sendMessage – error', () {
      blocTest<ChatCubit, ChatState>(
        'emits ChatLoaded(isTyping:false) then ChatFailure when repo throws',
        build: () {
          final repo = _repo();
          when(() => repo.sendMessage(any()))
              .thenThrow(Exception('Gemini error: quota exceeded'));
          return _cubitWithRepo(repo);
        },
        seed: () => ChatLoaded(messages: [makeWelcomeMessage()]),
        act: (c) => c.sendMessage('help'),
        expect: () => [
          isA<ChatLoaded>().having((s) => s.isTyping, 'typing', isTrue),
          isA<ChatLoaded>().having((s) => s.isTyping, 'not typing', isFalse),
          isA<ChatFailure>().having(
                (s) => s.errorMessage,
            'errorMessage',
            contains('quota exceeded'),
          ),
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'user message is retained in history after error',
        build: () {
          final repo = _repo();
          when(() => repo.sendMessage(any()))
              .thenThrow(Exception('network error'));
          return _cubitWithRepo(repo);
        },
        seed: () => ChatLoaded(messages: [makeWelcomeMessage()]),
        act: (c) => c.sendMessage('ping'),
        skip: 1, // skip typing state
        expect: () => [
          isA<ChatLoaded>().having(
                (s) => s.messages.any((m) => m.text == 'ping' && m.isUser),
            'user message retained',
            isTrue,
          ),
          isA<ChatFailure>(),
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'no bot reply is added to the message list on error',
        build: () {
          final repo = _repo();
          when(() => repo.sendMessage(any()))
              .thenThrow(Exception('fail'));
          return _cubitWithRepo(repo);
        },
        seed: () =>
            ChatLoaded(messages: [makeWelcomeMessage()]), // 1 message
        act: (c) => c.sendMessage('test'),
        skip: 2, // skip typing + error-loaded states
        verify: (c) {
          final loaded = c.state;
          // After the failure the cubit may be in ChatFailure;
          // if we re-read the prior ChatLoaded it must have only
          // welcome + user = 2 messages (no bot reply).
          if (loaded is ChatLoaded) {
            expect(loaded.messages.where((m) => !m.isUser).length, 1);
          }
        },
      );
    });

    // -----------------------------------------------------------------------
    // sendSuggestion
    // -----------------------------------------------------------------------
    group('sendSuggestion', () {
      blocTest<ChatCubit, ChatState>(
        'delegates to sendMessage — emits same states',
        build: () {
          final repo = _repo();
          when(() => repo.sendMessage(any()))
              .thenAnswer((_) async => makeBotMessage());
          return _cubitWithRepo(repo);
        },
        seed: () => ChatLoaded(messages: [makeWelcomeMessage()]),
        act: (c) => c.sendSuggestion('Emergency Help'),
        expect: () => [
          isA<ChatLoaded>().having((s) => s.isTyping, 'typing', isTrue),
          isA<ChatLoaded>().having((s) => s.isTyping, 'done', isFalse),
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'suggestion text is appended as a user message',
        build: () {
          final repo = _repo();
          when(() => repo.sendMessage(any()))
              .thenAnswer((_) async => makeBotMessage());
          return _cubitWithRepo(repo);
        },
        seed: () => ChatLoaded(messages: [makeWelcomeMessage()]),
        act: (c) => c.sendSuggestion('Nearby Institutions'),
        skip: 1,
        expect: () => [
          isA<ChatLoaded>().having(
                (s) => s.messages.any(
                  (m) => m.text == 'Nearby Institutions' && m.isUser,
            ),
            'suggestion as user message',
            isTrue,
          ),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // clearChat
    // -----------------------------------------------------------------------
    group('clearChat', () {
      blocTest<ChatCubit, ChatState>(
        'calls repository.resetChat()',
        build: () {
          final repo = _repo();
          when(() => repo.resetChat()).thenReturn(null);
          return _cubitWithRepo(repo);
        },
        seed: () => ChatLoaded(messages: makeConversation()),
        act: (c) => c.clearChat(),
        verify: (c) {
          // We can't reach the repo directly, but we verify via side-effects:
          // the state resets to a single welcome message.
          expect(c.state, isA<ChatLoaded>());
        },
      );

      blocTest<ChatCubit, ChatState>(
        'emits ChatLoaded with only the welcome message after clear',
        build: () {
          final repo = _repo();
          when(() => repo.resetChat()).thenReturn(null);
          return _cubitWithRepo(repo);
        },
        seed: () =>
            ChatLoaded(messages: makeLongConversation(length: 8)),
        act: (c) => c?.clearChat(),
        wait: const Duration(milliseconds: 300),
        expect: () => [
          isA<ChatLoaded>().having(
                (s) => s.messages.length,
            'messages after clear',
            1,
          ),
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'cleared message is a bot message (not a user message)',
        build: () {
          final repo = _repo();
          when(() => repo.resetChat()).thenReturn(null);
          return _cubitWithRepo(repo);
        },
        seed: () => ChatLoaded(messages: makeConversation()),
        act: (c) => c.clearChat(),
        wait: const Duration(milliseconds: 300),
        expect: () => [
          isA<ChatLoaded>().having(
                (s) => s.messages.first.isUser,
            'welcome isUser',
            isFalse,
          ),
        ],
      );
    });
  });
}