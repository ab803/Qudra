import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/Chat_Bot/view%20model/chat_cubit.dart';
import 'package:qudra_0/Feature/Chat_Bot/views/chat_bot_view.dart';
import 'package:qudra_0/Feature/Chat_Bot/widgets/chat_message_tile.dart';
import 'package:qudra_0/Feature/Chat_Bot/widgets/chat_suggestion_pill.dart';
import 'package:qudra_0/Feature/Chat_Bot/widgets/chat_typing_indicator.dart';
import 'Chat mock classes.dart';
import 'Chat test data.dart';

// ---------------------------------------------------------------------------
// App builder
// ---------------------------------------------------------------------------

Widget _app(ChatCubit cubit) {
  return MaterialApp(
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: BlocProvider<ChatCubit>.value(
      value: cubit,
      child: const ChatBotView(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockChatRepository repo;

  setUp(registerChatFallbacks);

  setUp(() {
    repo = MockChatRepository();
  });

  // -----------------------------------------------------------------------
  // Flow 1: Boot → welcome message appears
  // -----------------------------------------------------------------------
  group('Boot flow', () {
    testWidgets('welcome message is visible after cubit initialises',
            (tester) async {
          final cubit = ChatCubit();
          addTearDown(cubit.close);

          await tester.pumpWidget(_app(cubit));
          // Allow _init() async to complete.
          await tester.pumpAndSettle();

          expect(find.byType(ChatMessageTile), findsOneWidget);

          final tile = tester.widget<ChatMessageTile>(
            find.byType(ChatMessageTile),
          );
          expect(tile.isUser, isFalse);
        });
  });

  // -----------------------------------------------------------------------
  // Flow 2: User sends message → typing indicator → bot reply appears
  // -----------------------------------------------------------------------
  group('Send message flow', () {
    testWidgets(
      'typing indicator appears and then bot reply is rendered after send',
          (tester) async {
        final completer = Completer<void>();

        when(() => repo.sendMessage(any())).thenAnswer((_) async {
          await completer.future; // hold the response until we check typing
          return makeBotMessage(text: 'Here is the nearest clinic.');
        });

        final cubit = ChatCubit();
        addTearDown(cubit.close);

        await tester.pumpWidget(_app(cubit));
        await tester.pumpAndSettle(); // let init complete

        // Enter and send a message.
        await tester.enterText(find.byType(TextField), 'nearest clinic');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pump(); // let the typing state propagate

        // Typing indicator must be visible while waiting.
        expect(find.byType(ChatTypingIndicator), findsOneWidget);

        // Release the response.
        completer.complete();
        await tester.pumpAndSettle();

        // Typing indicator gone; bot reply visible.
        expect(find.byType(ChatTypingIndicator), findsNothing);
        expect(find.textContaining('nearest clinic.'), findsOneWidget);
      },
    );

    testWidgets('user message tile appears immediately after send',
            (tester) async {
          when(() => repo.sendMessage(any()))
              .thenAnswer((_) async => makeBotMessage());

          final cubit = ChatCubit();
          addTearDown(cubit.close);

          await tester.pumpWidget(_app(cubit));
          await tester.pumpAndSettle();

          final beforeCount = tester
              .widgetList<ChatMessageTile>(find.byType(ChatMessageTile))
              .length;

          await tester.enterText(find.byType(TextField), 'Can you help?');
          await tester.tap(find.byIcon(Icons.send));
          await tester.pump();

          // After the first pump the user tile is added.
          final afterCount = tester
              .widgetList<ChatMessageTile>(find.byType(ChatMessageTile))
              .length;

          expect(afterCount, greaterThan(beforeCount));
        });

    testWidgets('text field is cleared immediately after tapping send',
            (tester) async {
          when(() => repo.sendMessage(any()))
              .thenAnswer((_) async => makeBotMessage());

          final cubit = ChatCubit();
          addTearDown(cubit.close);

          await tester.pumpWidget(_app(cubit));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), 'My message');
          await tester.tap(find.byIcon(Icons.send));
          await tester.pump();

          final field = tester.widget<TextField>(find.byType(TextField));
          expect(field.controller?.text ?? '', isEmpty);
        });
  });

  // -----------------------------------------------------------------------
  // Flow 3: Repository throws → SnackBar shown, user message retained
  // -----------------------------------------------------------------------
  group('Error flow', () {
    testWidgets('SnackBar is shown when the repository throws', (tester) async {
      when(() => repo.sendMessage(any()))
          .thenThrow(Exception('Gemini error: quota exceeded'));

      final cubit = ChatCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(_app(cubit));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'help');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('user message is still visible in list after error',
            (tester) async {
          when(() => repo.sendMessage(any()))
              .thenThrow(Exception('network error'));

          final cubit = ChatCubit();
          addTearDown(cubit.close);

          await tester.pumpWidget(_app(cubit));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), 'wheelchair services');
          await tester.tap(find.byIcon(Icons.send));
          await tester.pumpAndSettle();

          expect(find.textContaining('wheelchair services'), findsOneWidget);
        });
  });

  // -----------------------------------------------------------------------
  // Flow 4: Suggestion pill → full round-trip
  // -----------------------------------------------------------------------
  group('Suggestion pill flow', () {
    testWidgets('tapping a suggestion pill sends it as a user message',
            (tester) async {
          when(() => repo.sendMessage(any()))
              .thenAnswer((_) async => makeBotMessage(text: 'Emergency details.'));

          final cubit = ChatCubit();
          addTearDown(cubit.close);

          await tester.pumpWidget(_app(cubit));
          await tester.pumpAndSettle();

          await tester.tap(find.byType(ChatSuggestionPill).first);
          await tester.pumpAndSettle();

          // A user tile and a bot reply tile should now exist.
          final userTiles = tester
              .widgetList<ChatMessageTile>(find.byType(ChatMessageTile))
              .where((t) => t.isUser)
              .toList();
          expect(userTiles, isNotEmpty);
        });
  });

  // -----------------------------------------------------------------------
  // Flow 5: Clear chat → history is wiped, welcome message reappears
  // -----------------------------------------------------------------------
  group('Clear chat flow', () {
    testWidgets('tapping the clear button resets history to welcome only',
            (tester) async {
          when(() => repo.sendMessage(any()))
              .thenAnswer((_) async => makeBotMessage());
          when(() => repo.resetChat()).thenReturn(null);

          final cubit = ChatCubit();
          addTearDown(cubit.close);

          await tester.pumpWidget(_app(cubit));
          await tester.pumpAndSettle();

          // Send a message to build up some history.
          await tester.enterText(find.byType(TextField), 'test message');
          await tester.tap(find.byIcon(Icons.send));
          await tester.pumpAndSettle();

          // More than one tile now.
          expect(
            find.byType(ChatMessageTile),
            findsWidgets,
          );

          // Clear.
          await tester.tap(find.byIcon(Icons.refresh));
          await tester.pumpAndSettle();

          // Only the welcome tile remains.
          expect(find.byType(ChatMessageTile), findsOneWidget);
        });

    testWidgets('clearChat calls repository.resetChat()', (tester) async {
      when(() => repo.sendMessage(any()))
          .thenAnswer((_) async => makeBotMessage());
      when(() => repo.resetChat()).thenReturn(null);

      final cubit = ChatCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(_app(cubit));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      verify(() => repo.resetChat()).called(1);
    });
  });
}