import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconic_studio_pro/main.dart';

void main() {
  testWidgets('App renders with dark theme', (WidgetTester tester) async {
    await tester.pumpWidget(const IconicStudioApp());

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.scaffoldBackgroundColor?.toARGB32(), 0xFF0A0A0A);
  });
}
