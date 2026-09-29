import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  Size size = const Size(400, 800),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildNeutralTheme(brightness),
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: app!,
      ),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('LoadingView', () {
    testWidgets('shows a spinner with the given semantics label', (
      tester,
    ) async {
      await _pump(tester, const LoadingView(semanticsLabel: 'Loading!'));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester
            .widget<CircularProgressIndicator>(
              find.byType(CircularProgressIndicator),
            )
            .semanticsLabel,
        'Loading!',
      );
    });

    testWidgets('works without a label', (tester) async {
      await _pump(tester, const LoadingView());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('ErrorView', () {
    testWidgets('shows the message and its icon', (tester) async {
      await _pump(
        tester,
        const ErrorView(message: 'Boom', icon: Icons.cloud_off),
      );

      expect(find.text('Boom'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('has no button unless an action is given', (tester) async {
      await _pump(tester, const ErrorView(message: 'Boom'));

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('shows the action label and calls it on tap', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        ErrorView(
          message: 'Boom',
          action: ViewAction(label: 'Again', onPressed: () => taps++),
        ),
      );

      await tester.tap(find.text('Again'));

      expect(taps, 1);
    });

    testWidgets('announces the message to a screen reader as it appears', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const ErrorView(message: 'Boom'));

      expect(
        tester.getSemantics(find.text('Boom')),
        matchesSemantics(label: 'Boom', isLiveRegion: true),
      );
      handle.dispose();
    });

    testWidgets('the icon is muted, from the theme, not a literal', (
      tester,
    ) async {
      await _pump(tester, const ErrorView(message: 'Boom'));

      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.color, AppColors.neutralLight.textMuted);
      expect(icon.size, AppSizes.iconL);
    });

    testWidgets('follows the dark palette', (tester) async {
      await _pump(
        tester,
        const ErrorView(message: 'Boom'),
        brightness: Brightness.dark,
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.color, AppColors.neutralDark.textMuted);
    });
  });

  group('EmptyView', () {
    testWidgets('shows the message and an optional action', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        EmptyView(
          message: 'Nothing here',
          action: ViewAction(label: 'Clear', onPressed: () => taps++),
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      await tester.tap(find.text('Clear'));
      expect(taps, 1);
    });

    testWidgets('has no button without an action', (tester) async {
      await _pump(tester, const EmptyView(message: 'Nothing here'));

      expect(find.byType(FilledButton), findsNothing);
    });
  });

  group('layout', () {
    const longGerman =
        'Auf unserer Seite ist etwas schiefgelaufen. Bitte versuchen Sie es '
        'später erneut, und wenn das Problem weiterhin besteht, wenden Sie '
        'sich bitte an den Support Ihres Anbieters.';

    testWidgets('a long message wraps on a narrow screen with large text', (
      tester,
    ) async {
      await _pump(
        tester,
        ErrorView(
          message: longGerman,
          action: ViewAction(label: 'Erneut versuchen', onPressed: () {}),
        ),
        size: const Size(280, 500),
        textScale: 2,
      );

      // A RenderFlex overflow would be reported as a test exception.
      expect(tester.takeException(), isNull);
      expect(find.text(longGerman), findsOneWidget);
    });

    testWidgets('scrolls instead of overflowing when very short', (
      tester,
    ) async {
      await _pump(
        tester,
        ErrorView(
          message: longGerman,
          action: ViewAction(label: 'Erneut versuchen', onPressed: () {}),
        ),
        size: const Size(280, 200),
        textScale: 2,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('a wide screen keeps the content at a readable width', (
      tester,
    ) async {
      await _pump(
        tester,
        const ErrorView(message: 'Boom'),
        size: const Size(2000, 800),
      );

      final width = tester.getSize(find.byType(Column).first).width;
      expect(width, lessThanOrEqualTo(AppSizes.maxContentWidth));
    });
  });
}
