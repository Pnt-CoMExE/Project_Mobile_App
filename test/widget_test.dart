import 'package:flutter_test/flutter_test.dart';

import 'package:project_mobile_app/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SportBorrowingApp());
    expect(find.text('Welcome'), findsWidgets);
  });
}
