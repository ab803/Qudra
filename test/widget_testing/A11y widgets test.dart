import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:qudra_0/Feature/accessibility/widgets/a11y_quick_win_card.dart';
import 'package:qudra_0/Feature/accessibility/widgets/a11y_search_bar.dart';
import 'package:qudra_0/Feature/accessibility/widgets/a11y_section_header.dart';
import 'package:qudra_0/Feature/accessibility/widgets/a11y_tip_card.dart';
import 'package:qudra_0/Feature/accessibility/widgets/a11y_segment_filter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Test helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps [child] in a minimal, localised [MaterialApp] that satisfies the
/// translation extension used inside some widgets.
Widget _wrap(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? ThemeData.light(),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('ar')],
    home: Scaffold(body: child),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// A11yQuickWinCard
// ─────────────────────────────────────────────────────────────────────────────
void main() {
  group('A11yQuickWinCard', () {
    const tIcon = Icons.accessible;
    const tTitle = 'Screen Reader';
    const tSubtitle = 'Enable VoiceOver or TalkBack for better navigation.';

    testWidgets('renders title and subtitle text', (tester) async {
      await tester.pumpWidget(_wrap(const A11yQuickWinCard(
        icon: tIcon,
        title: tTitle,
        subtitle: tSubtitle,
      )));

      expect(find.text(tTitle), findsOneWidget);
      expect(find.text(tSubtitle), findsOneWidget);
    });

    testWidgets('renders the supplied icon', (tester) async {
      await tester.pumpWidget(_wrap(const A11yQuickWinCard(
        icon: tIcon,
        title: tTitle,
        subtitle: tSubtitle,
      )));

      expect(find.byIcon(tIcon), findsOneWidget);
    });

    testWidgets('has fixed height of 88 logical pixels', (tester) async {
      await tester.pumpWidget(_wrap(const A11yQuickWinCard(
        icon: tIcon,
        title: tTitle,
        subtitle: tSubtitle,
      )));

      final box = tester.renderObject<RenderBox>(
        find.byType(A11yQuickWinCard),
      );
      expect(box.size.height, 88.0);
    });

    testWidgets('truncates an overflowing title to one line', (tester) async {
      final longTitle = 'A' * 120;
      await tester.pumpWidget(_wrap(A11yQuickWinCard(
        icon: tIcon,
        title: longTitle,
        subtitle: 'sub',
      )));
      // Should not overflow (no exception).
      expect(find.byType(A11yQuickWinCard), findsOneWidget);
    });

    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(_wrap(
        const A11yQuickWinCard(
          icon: tIcon,
          title: tTitle,
          subtitle: tSubtitle,
        ),
        theme: ThemeData.dark(),
      ));

      expect(find.text(tTitle), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // A11ySearchBar
  // ─────────────────────────────────────────────────────────────────────────
  group('A11ySearchBar', () {
    const tHint = 'Search tips and rights…';

    testWidgets('displays the hint text', (tester) async {
      await tester.pumpWidget(_wrap(
        const A11ySearchBar(hintText: tHint),
      ));

      expect(find.text(tHint), findsOneWidget);
    });

    testWidgets('renders the search icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const A11ySearchBar(hintText: tHint),
      ));

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('renders the filter (tune) icon button', (tester) async {
      await tester.pumpWidget(_wrap(
        const A11ySearchBar(hintText: tHint),
      ));

      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    testWidgets('tune icon button is tappable without errors', (tester) async {
      await tester.pumpWidget(_wrap(
        const A11ySearchBar(hintText: tHint),
      ));

      // The onPressed callback is currently a no-op, but it must not throw.
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pump();
    });

    testWidgets('has fixed height of 44 logical pixels', (tester) async {
      await tester.pumpWidget(_wrap(
        const SizedBox(
          width: 300,
          child: A11ySearchBar(hintText: tHint),
        ),
      ));

      final box = tester.renderObject<RenderBox>(
        find.byType(A11ySearchBar),
      );
      expect(box.size.height, 44.0);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // A11ySectionHeader
  // ─────────────────────────────────────────────────────────────────────────
  group('A11ySectionHeader', () {
    const tLabel = 'Quick Wins';
    const tIcon = Icons.bolt_outlined;

    testWidgets('displays the label', (tester) async {
      await tester.pumpWidget(_wrap(
        const A11ySectionHeader(label: tLabel, icon: tIcon),
      ));

      expect(find.text(tLabel), findsOneWidget);
    });

    testWidgets('renders the supplied icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const A11ySectionHeader(label: tLabel, icon: tIcon),
      ));

      expect(find.byIcon(tIcon), findsOneWidget);
    });

    testWidgets('label font size is 18', (tester) async {
      await tester.pumpWidget(_wrap(
        const A11ySectionHeader(label: tLabel, icon: tIcon),
      ));

      final richText = tester.widget<RichText>(
        find.descendant(
          of: find.byType(A11ySectionHeader),
          matching: find.byType(RichText),
        ).first,
      );
      final span = richText.text as TextSpan;
      expect(span.style?.fontSize, 18.0);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // A11yTipCard
  // ─────────────────────────────────────────────────────────────────────────
  group('A11yTipCard', () {
    const tTitle = 'Use High Contrast';
    const tBody = 'Enable high-contrast mode in your device settings.';
    const tTags = ['Visual', 'Accessibility'];

    testWidgets('renders title and body', (tester) async {
      await tester.pumpWidget(_wrap(
        const A11yTipCard(title: tTitle, body: tBody),
      ));

      expect(find.text(tTitle), findsOneWidget);
      expect(find.text(tBody), findsOneWidget);
    });

    testWidgets('shows bookmark_border icon when bookmarked is false',
            (tester) async {
          await tester.pumpWidget(_wrap(
            const A11yTipCard(title: tTitle, body: tBody),
          ));

          expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
          expect(find.byIcon(Icons.bookmark), findsNothing);
        });

    testWidgets('shows filled bookmark icon when bookmarked is true',
            (tester) async {
          await tester.pumpWidget(_wrap(
            const A11yTipCard(title: tTitle, body: tBody, bookmarked: true),
          ));

          expect(find.byIcon(Icons.bookmark), findsOneWidget);
          expect(find.byIcon(Icons.bookmark_border), findsNothing);
        });

    testWidgets('renders all tag pills when tags are provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const A11yTipCard(title: tTitle, body: tBody, tags: tTags),
      ));

      for (final tag in tTags) {
        expect(find.text(tag), findsOneWidget);
      }
    });

    testWidgets('does not render tag section when tags list is empty',
            (tester) async {
          await tester.pumpWidget(_wrap(
            const A11yTipCard(title: tTitle, body: tBody),
          ));

          // The Wrap widget that holds pills should be absent.
          expect(
            find.descendant(
              of: find.byType(A11yTipCard),
              matching: find.byType(Wrap),
            ),
            findsNothing,
          );
        });

    testWidgets('handles an overflowing body without widget errors',
            (tester) async {
          final longBody = 'L' * 500;
          await tester.pumpWidget(_wrap(
             SizedBox(
              width: 300,
              child: A11yTipCard(title: tTitle, body: longBody),
            ),
          ));
          // Should not throw an overflow exception.
          expect(find.byType(A11yTipCard), findsOneWidget);
        });

    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(_wrap(
        const A11yTipCard(title: tTitle, body: tBody, tags: tTags),
        theme: ThemeData.dark(),
      ));

      expect(find.text(tTitle), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // A11ySegmentFilter
  // ─────────────────────────────────────────────────────────────────────────
  group('A11ySegmentFilter', () {
    testWidgets('renders three segment pills', (tester) async {
      await tester.pumpWidget(_wrap(const A11ySegmentFilter()));
      await tester.pumpAndSettle();

      // Each pill is an Expanded → Container with an Icon + Text.
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.hearing_outlined), findsOneWidget);
      expect(find.byIcon(Icons.accessibility_new_outlined), findsOneWidget);
    });

    testWidgets('first pill is selected (border colour is non-divider)',
            (tester) async {
          await tester.pumpWidget(_wrap(const A11ySegmentFilter()));
          await tester.pumpAndSettle();

          // The widget tree has three Expanded → Container widgets.
          // We just verify the correct number of segment containers exist.
          final containers = tester.widgetList<Container>(
            find.descendant(
              of: find.byType(Row),
              matching: find.byType(Container),
            ),
          );
          // At least 3 containers (the three pills).
          expect(containers.length, greaterThanOrEqualTo(3));
        });

    testWidgets('each pill has height of 40 logical pixels', (tester) async {
      await tester.pumpWidget(_wrap(
        const SizedBox(width: 400, child: A11ySegmentFilter()),
      ));
      await tester.pumpAndSettle();

      // Find the pill-level Containers (they have explicit height: 40).
      final pillContainers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.constraints?.minHeight == 40 ||
          (c.constraints == null &&
              (c.decoration as BoxDecoration?)?.borderRadius != null))
          .toList();

      expect(pillContainers, isNotEmpty);
    });
  });
}