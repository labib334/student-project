import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {

    await tester.pumpWidget(const StudentApp());

    expect(find.text('Login'), findsOneWidget);
  });
}