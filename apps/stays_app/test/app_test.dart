import 'package:flutter_test/flutter_test.dart';
import 'package:stays_app/src/app.dart';

void main() {
  testWidgets('the shell boots and shows the placeholder', (tester) async {
    await tester.pumpWidget(const StaysApp());

    expect(find.text('stays'), findsOneWidget);
  });
}
