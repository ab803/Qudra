import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/Chat_Bot/view%20model/chat_cubit.dart';
import 'package:qudra_0/Feature/Chat_Bot/view%20model/chat_state.dart';
import 'package:qudra_0/Feature/Chat_Bot/views/chat_bot_view.dart';
import 'package:qudra_0/Feature/Chat_Bot/widgets/chat_input_bar.dart';
import 'package:qudra_0/Feature/Chat_Bot/widgets/chat_message_tile.dart';
import 'package:qudra_0/Feature/Chat_Bot/widgets/chat_suggestion_pill.dart';
import 'package:qudra_0/Feature/Chat_Bot/widgets/chat_typing_indicator.dart';
import 'Chat mock classes.dart';
import 'Chat test data.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// A fake cubit that emits whatever state is given at construction time,
/// with a controllable stream for listener tests.
class _SeededChatCubit extends ChatCubit {
  final StreamController<ChatState> _controller;

  _SeededChatCubit(ChatState seed)
      : _controller = StreamController<ChatState>.broadcast(),
        super() {
    emit(seed);
  }

  @override
  Stream<ChatState> get stream => _controller.stream;

  void push(ChatState state) {
    emit(state);
    _controller.add(state);
  }

  @override
  Future<void> close() async {
    await _controller.close();
    return super.close();
  }
}

Widget _wrap(Widget child, ChatCubit cubit) {
  return MaterialApp(
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: BlocProvider<ChatCubit>.value(
      value: cubit,
      child: child,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(registerChatFallbacks);

  group('ChatBotView', () {
    // -----------------------------------------------------------------------
    // Loading / initial state
    // -----------------------------------------------------------------------
    group('loading state', () {
      testWidgets('shows CircularProgressIndicator when state is ChatInitial',
              (tester) async {
            final cubit = _SeededChatCubit(ChatInitial());
            addTearDown(cubit.close);

            await tester.pumpWidget(_wrap(const ChatBotView(), cubit));

            expect(find.byType(CircularProgressIndicator), findsOneWidget);
            expect(find.byType(ListView), findsNothing);
          });
    });

    // -----------------------------------------------------------------------
    // Message list — ChatLoaded
    // -----------------------------------------------------------------------
    group('message list', () {
      testWidgets('renders a ListView when state is ChatLoaded', (tester) async {
        final cubit = _SeededChatCubit(
          ChatLoaded(messages: [makeWelcomeMessage()]),
        );
        addTearDown(cubit.close);

        await tester.pumpWidget(_wrap(const ChatBotView(), cubit));

        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('renders one tile per message', (tester) async {
        final messages = [
          makeWelcomeMessage(),
          makeUserMessage(),
          makeBotMessage(),
        ];
        final cubit = _SeededChatCubit(ChatLoaded(messages: messages));
        addTearDown(cubit.close);

        await tester.pumpWidget(_wrap(const ChatBotView(), cubit));

        expect(find.byType(ChatMessageTile), findsNWidgets(3));
      });

      testWidgets('message text is visible in the list', (tester) async {
        final cubit = _SeededChatCubit(
          ChatLoaded(messages: [makeUserMessage(text: 'I need a wheelchair ramp')]),
        );
        addTearDown(cubit.close);

        await tester.pumpWidget(_wrap(const ChatBotView(), cubit));

        expect(find.textContaining('wheelchair ramp'), findsOneWidget);
      });

      testWidgets('shows ChatTypingIndicator when isTyping is true',
              (tester) async {
            final cubit = _SeededChatCubit(
              ChatLoaded(messages: [makeWelcomeMessage()], isTyping: true),
            );
            addTearDown(cubit.close);

            await tester.pumpWidget(_wrap(const ChatBotView(), cubit));

            expect(find.byType(ChatTypingIndicator), findsOneWidget);
          });

      testWidgets('hides ChatTypingIndicator when isTyping is false',
              (tester) async {
            final cubit = _SeededChatCubit(
              ChatLoaded(messages: [makeWelcomeMessage()], isTyping: false),
            );
            addTearDown(cubit.close);

            await tester.pumpWidget(_wrap(const ChatBotView(), cubit));

            expect(find.byType(ChatTypingIndicator), findsNothing);
          });

      testWidgets('typing indicator appears after the last real message',
              (tester) async {
            final messages = [makeUserMessage(text: 'Visible message')];
            final cubit = _SeededChatCubit(
              ChatLoaded(messages: messages, isTyping: true),
            );
            addTearDown(cubit.close);

            await tester.pumpWidget(_wrap(const ChatBotView(), cubit));

            // The list has 2 items: the message + the typing indicator.
            expect(find.byType(ChatMessageTile), findsOneWidget);
            expect(find.byType(ChatTypingIndicator), findsOneWidget);
          });
    });

    // -----------------------------------------------------------------------
    // Suggestion pills
    // -----------------------------------------------------------------------
    group('suggestion pills', () {
      testWidgets('renders four suggestion pills', (tester) async {
        final cubit = _SeededChatCubit(
          ChatLoaded(messages: [makeWelcomeMessage()]),
        );
        addTearDown(cubit.close);

        await tester.pumpWidget(_wrap(const ChatBotView(), cubit));

        expect(find.byType(ChatSuggestionPill), findsNWidgets(4));
      });

      testWidgets('tapping a suggestion pill calls sendSuggestion on the cubit',
              (tester) async {
            final mock = MockChatCubit();
            when(() => mock.state)
                .thenReturn(ChatLoaded(messages: [makeWelcomeMessage()]));
            when(() => mock.stream).thenAnswer((_) => const Stream.empty());
            when(() => mock.sendSuggestion(any())).thenAnswer((_) async {});

            await tester.pumpWidget(_wrap(const ChatBotView(), mock));

            await tester.tap(find.byType(ChatSuggestionPill).first);
            await tester.pump();

            verify(() => mock.sendSuggestion(any())).called(1);
          });

      testWidgets('first suggestion pill is styled as critical (emergency)',
              (tester) async {
            final cubit = _SeededChatCubit(
              ChatLoaded(messages: [makeWelcomeMessage()]),
            );
            addTearDown(cubit.close);

            await tester.pumpWidget(_wrap(const ChatBotView(), cubit));

            final pills = tester.widgetList<ChatSuggestionPill>(
              find.byType(ChatSuggestionPill),
            );
            expect(pills.first.isCritical, isTrue);
          });

      testWidgets('non-emergency suggestion pills are not critical',
              (tester) async {
            final cubit = _SeededChatCubit(
              ChatLoaded(messages: [makeWelcomeMessage()]),
            );
            addTearDown(cubit.close);

            await tester.pumpWidget(_wrap(const ChatBotView(), cubit));

            final pills = tester.widgetList<ChatSuggestionPill>(
              find.byType(ChatSuggestionPill),
            ).toList();

            for (final pill in pills.skip(1)) {
              expect(pill.isCritical, isFalse);
            }
          });
    });

    // -----------------------------------------------------------------------
    // Input bar
    // -----------------------------------------------------------------------
    group('input bar', () {
      testWidgets('ChatInputBar is rendered', (tester) async {
        final cubit = _SeededChatCubit(
          ChatLoaded(messages: [makeWelcomeMessage()]),
        );
        addTearDown(cubit.close);

        await tester.pumpWidget(_wrap(const ChatBotView(), cubit));

        expect(find.byType(ChatInputBar), findsOneWidget);
      });

      testWidgets('entering text and tapping send calls sendMessage on cubit',
              (tester) async {
            final mock = MockChatCubit();
            when(() => mock.state)
                .thenReturn(ChatLoaded(messages: [makeWelcomeMessage()]));
            when(() => mock.stream).thenAnswer((_) => const Stream.empty());
            when(() => mock.sendMessage(any())).thenAnswer((_) async {});

            await tester.pumpWidget(_wrap(const ChatBotView(), mock));

            await tester.enterText(find.byType(TextField), 'Where is the nearest clinic?');
            // Tap the send button inside ChatInputBar.
            await tester.tap(find.byIcon(Icons.send));
            await tester.pump();

            verify(() => mock.sendMessage('Where is the nearest clinic?')).called(1);
          });

      testWidgets('text field is cleared after sending', (tester) async {
        final mock = MockChatCubit();
        when(() => mock.state)
            .thenReturn(ChatLoaded(messages: [makeWelcomeMessage()]));
        when(() => mock.stream).thenAnswer((_) => const Stream.empty());
        when(() => mock.sendMessage(any())).thenAnswer((_) async {});

        await tester.pumpWidget(_wrap(const ChatBotView(), mock));

        await tester.enterText(find.byType(TextField), 'Hello');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pump();

        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.controller?.text ?? '', isEmpty);
      });

      testWidgets('does not call sendMessage when text field is empty',
              (tester) async {
            final mock = MockChatCubit();
            when(() => mock.state)
                .thenReturn(ChatLoaded(messages: [makeWelcomeMessage()]));
            when(() => mock.stream).thenAnswer((_) => const Stream.empty());
            when(() => mock.sendMessage(any())).thenAnswer((_) async {});

            await tester.pumpWidget(_wrap(const ChatBotView(), mock));

            // Tap send without entering text.
            await tester.tap(find.byIcon(Icons.send));
            await tester.pump();

            verifyNever(() => mock.sendMessage(any()));
          });
    });

    // -----------------------------------------------------------------------
    // AppBar
    // -----------------------------------------------------------------------
    group('app bar', () {
      testWidgets('AppBar is present', (tester) async {
        final cubit = _SeededChatCubit(ChatLoaded(messages: []));
        addTearDown(cubit.close);

        await tester.pumpWidget(_wrap(const ChatBotView(), cubit));

        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('clear (refresh) button calls clearChat on the cubit',
              (tester) async {
            final mock = MockChatCubit();
            when(() => mock.state)
                .thenReturn(ChatLoaded(messages: [makeWelcomeMessage()]));
            when(() => mock.stream).thenAnswer((_) => const Stream.empty());
            when(() => mock.clearChat()).thenReturn(null);

            await tester.pumpWidget(_wrap(const ChatBotView(), mock));

            await tester.tap(find.byIcon(Icons.refresh));
            await tester.pump();

            verify(() => mock.clearChat()).called(1);
          });

      testWidgets('back button is present in the AppBar', (tester) async {
        final cubit = _SeededChatCubit(ChatLoaded(messages: []));
        addTearDown(cubit.close);

        await tester.pumpWidget(_wrap(const ChatBotView(), cubit));

        expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
      });

      testWidgets('online status indicator dot is rendered', (tester) async {
        final cubit = _SeededChatCubit(ChatLoaded(messages: []));
        addTearDown(cubit.close);

        await tester.pumpWidget(_wrap(const ChatBotView(), cubit));

        // The green circle container is 6×6 inside the AppBar title column.
        final greenDots = tester
            .widgetList<Container>(find.byType(Container))
            .where((c) =>
        c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color == Colors.green)
            .toList();
        expect(greenDots, isNotEmpty);
      });
    });

    // -----------------------------------------------------------------------
    // ChatFailure — SnackBar
    // -----------------------------------------------------------------------
    group('ChatFailure listener', () {
      testWidgets('shows a SnackBar when state transitions to ChatFailure',
              (tester) async {
            final cubit = _SeededChatCubit(
              ChatLoaded(messages: [makeWelcomeMessage()]),
            );
            addTearDown(cubit.close);

            await tester.pumpWidget(_wrap(const ChatBotView(), cubit));

            cubit.push(
               ChatFailure(errorMessage: 'Gemini error: quota exceeded'),
            );

            await tester.pump();
            await tester.pump(const Duration(seconds: 1));

            expect(find.byType(SnackBar), findsOneWidget);
            expect(find.textContaining('quota exceeded'), findsOneWidget);
          });

      testWidgets('SnackBar has floating behaviour', (tester) async {
        final cubit = _SeededChatCubit(
          ChatLoaded(messages: [makeWelcomeMessage()]),
        );
        addTearDown(cubit.close);

        await tester.pumpWidget(_wrap(const ChatBotView(), cubit));
        cubit.push( ChatFailure(errorMessage: 'error'));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.behavior, SnackBarBehavior.floating);
      });
    });
  });
}