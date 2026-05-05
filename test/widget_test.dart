import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:iconic_studio_pro/main.dart';
import 'package:iconic_studio_pro/app_colors.dart';

// ---------------------------------------------------------------------------
// Tests pump StudioPage directly inside a bare MaterialApp so we bypass the
// async AuthGate SharedPreferences load that would prevent the studio UI from
// rendering in a single pumpWidget call.
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    // Provide a clean, in-memory SharedPreferences for every test.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('StudioPage renders without crashing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: StudioPage()),
    );
    // Allow the async EditorStorage.load() to complete.
    await tester.pumpAndSettle();

    // The app bar title should be visible.
    expect(find.text('Iconic Studio Pro'), findsOneWidget);
  });

  testWidgets('StudioPage shows import and export action icons', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: StudioPage()),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.file_upload_outlined), findsOneWidget);
    expect(find.byIcon(Icons.download_outlined),    findsOneWidget);
  });

  testWidgets('StudioPage shows upload zone when no image is loaded',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: StudioPage()),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);
    expect(find.text('Tap "Import Image" to begin'),        findsOneWidget);
  });

  testWidgets('StudioPage stats bar shows FPS, IMPORTS, SCALE, ROTATE',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: StudioPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('FPS'),     findsOneWidget);
    expect(find.text('IMPORTS'), findsOneWidget);
    expect(find.text('SCALE'),   findsOneWidget);
    expect(find.text('ROTATE'),  findsOneWidget);
  });

  testWidgets('Control panel sliders are present', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: StudioPage()),
    );
    await tester.pumpAndSettle();

    // Section headers
    expect(find.text('TRANSFORM'), findsOneWidget);
    expect(find.text('IMAGE'),     findsOneWidget);
    expect(find.text('DIAMOND'),   findsOneWidget);

    // Slider labels
    expect(find.text('Scale'),       findsOneWidget);
    expect(find.text('Rotation'),    findsOneWidget);
    expect(find.text('Brightness'),  findsOneWidget);
    expect(find.text('Contrast'),    findsOneWidget);
    expect(find.text('Saturation'),  findsOneWidget);
    expect(find.text('Blur'),        findsOneWidget);
    expect(find.text('Refraction'),  findsOneWidget);
    expect(find.text('Sparkle'),     findsOneWidget);
    expect(find.text('Facet Depth'), findsOneWidget);
  });

  testWidgets('EditorState.copyWith preserves unchanged fields', (tester) async {
    const original = EditorState(brightness: 1.5, contrast: 0.8);
    final updated  = original.copyWith(brightness: 2.0);

    expect(updated.brightness, 2.0);
    expect(updated.contrast,   0.8); // unchanged
    expect(updated.saturation, 1.0); // default
  });

  testWidgets('EditorState.copyWith can clear userImageBytes', (tester) async {
    final bytes    = Uint8List.fromList([1, 2, 3]);
    final withImg  = EditorState(userImageBytes: bytes);
    final cleared  = withImg.copyWith(clearImage: true);

    expect(cleared.userImageBytes, isNull);
  });

  testWidgets('AppColors constants are non-null', (tester) async {
    expect(AppColors.background,    isNotNull);
    expect(AppColors.gold,          isNotNull);
    expect(AppColors.textPrimary,   isNotNull);
    expect(AppColors.textSecondary, isNotNull);
    expect(AppColors.panel,         isNotNull);
  });

  testWidgets('Reset button appears in control panel', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: StudioPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reset'), findsOneWidget);
  });
}
