import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconic_studio_pro/main.dart';

void main() {
  group('App launch smoke', () {
    testWidgets('renders key studio UI', (tester) async {
      await tester.pumpWidget(const IconicStudioApp());

      expect(find.text('IconStudio'), findsOneWidget);
      expect(find.text('Export Icon'), findsOneWidget);
    });
  });

  group('EditorState immutability + copyWith', () {
    test('copyWith returns updated copy without mutating original', () {
      final original = EditorState(scale: 60, rotation: 10, brightness: 100);
      final updated = original.copyWith(scale: 72, contrast: 140);

      expect(updated, isNot(same(original)));
      expect(original.scale, 60);
      expect(original.contrast, 100);
      expect(updated.scale, 72);
      expect(updated.rotation, 10);
      expect(updated.contrast, 140);
    });
  });

  group('Export button presence', () {
    testWidgets('export button is present and tappable', (tester) async {
      await tester.pumpWidget(const IconicStudioApp());

      final exportButton = find.widgetWithText(ElevatedButton, 'Export Icon');
      expect(exportButton, findsOneWidget);

      await tester.tap(exportButton);
      await tester.pump();
    });
  });

  group('ShaderBuilder widget mounting', () {
    testWidgets('ShaderBuilder can be mounted in widget tree', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShaderBuilder(
              assetKey: 'shaders/diamond_master.frag',
              (context, shader, child) => SizedBox.shrink(),
            ),
          ),
        ),
      );

      expect(find.byType(ShaderBuilder), findsOneWidget);
    });
  });

  group('Color API withValues guard', () {
    testWidgets('app theme slider overlay uses expected withValues color', (
      tester,
    ) async {
      await tester.pumpWidget(const IconicStudioApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final overlayColor = materialApp.theme?.sliderTheme.overlayColor;

      expect(overlayColor, AppColors.gold.withValues(alpha: 0.2));
    });
  });
}
