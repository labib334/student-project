import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('🎓 Student System'), findsOneWidget);
  });
}