import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PagedState<String> _page(List<String> items, {String? nextCursor}) =>
    PagedState.fromFirstPage(CursorPage(items: items, nextCursor: nextCursor));

Future<void> _pump(
  WidgetTester tester,
  PagedState<String> paged, {
  required VoidCallback onLoadMore,
  Widget? header,
}) async {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildNeutralTheme(Brightness.light),
      home: Scaffold(
        body: PagedListView<String>(
          paged: paged,
          onLoadMore: onLoadMore,
          failureText: (_) => 'Our own words',
          retryLabel: 'Retry',
          loadingLabel: 'Loading',
          header: header,
          itemBuilder: (context, item) => Text(item),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('PagedListView', () {
    testWidgets('shows the header and every item', (tester) async {
      await _pump(
        tester,
        _page(['a', 'b']),
        onLoadMore: () {},
        header: const Text('2 results'),
      );

      expect(find.text('2 results'), findsOneWidget);
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
    });

    testWidgets('a short list with more pages asks for the next one', (
      tester,
    ) async {
      var calls = 0;

      await _pump(
        tester,
        _page(['a'], nextCursor: 'next'),
        onLoadMore: () => calls++,
      );

      expect(calls, greaterThan(0));
    });

    testWidgets('asks for nothing at the end of the list', (tester) async {
      var calls = 0;

      await _pump(tester, _page(['a']), onLoadMore: () => calls++);

      expect(calls, 0);
    });

    testWidgets('shows a spinner while a page is on its way', (tester) async {
      await _pump(
        tester,
        _page(['a'], nextCursor: 'next').loadingMore(),
        onLoadMore: () {},
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('a failed page shows our words, does not loop, and Retry asks '
        'again', (tester) async {
      var calls = 0;
      final failed = _page([
        'a',
      ], nextCursor: 'next').loadMoreFailed(const NetworkFailure());

      await _pump(tester, failed, onLoadMore: () => calls++);

      expect(find.text('Our own words'), findsOneWidget);
      expect(calls, 0);

      await tester.tap(find.text('Retry'));
      expect(calls, 1);
    });
  });
}
