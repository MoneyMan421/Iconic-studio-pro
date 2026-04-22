import 'package:flutter_test/flutter_test.dart';
import 'package:iconic_studio_pro/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const IconicStudioApp());

    expect(find.byType(PreviewCanvas), findsOneWidget);
  });
}
