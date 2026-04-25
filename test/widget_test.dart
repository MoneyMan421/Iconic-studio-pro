import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconic_studio_pro/main.dart';

void main() {
  setUp(() {
    // Provide in-memory SharedPreferences so tests don't hit the filesystem.
    SharedPreferences.setMockInitialValues({});
  });

  group('EditorState', () {
    test('default values are correct', () {
      const state = EditorState();
      expect(state.scale,            50);
      expect(state.rotation,         0);
      expect(state.brightness,       100);
      expect(state.contrast,         100);
      expect(state.saturation,       100);
      expect(state.blur,             0);
      expect(state.refractionIndex,  2.42);
      expect(state.sparkleIntensity, 0.8);
      expect(state.facetDepth,       0.6);
      expect(state.userImage,        isNull);
    });

    test('copyWith changes only specified fields', () {
      const base = EditorState();
      final updated = base.copyWith(brightness: 150, blur: 5.0);
      expect(updated.brightness,      150);
      expect(updated.blur,            5.0);
      // unchanged fields stay the same
      expect(updated.scale,           base.scale);
      expect(updated.refractionIndex, base.refractionIndex);
    });

    test('copyWith with no arguments returns equivalent state', () {
      const base = EditorState(scale: 75, rotation: 45);
      final copy = base.copyWith();
      expect(copy.scale,    base.scale);
      expect(copy.rotation, base.rotation);
    });
  });

  group('AppColors', () {
    test('gold colour is correct', () {
      expect(AppColors.gold.toARGB32(), const Color(0xFFD4AF37).toARGB32());
    });

    test('background colour is correct', () {
      expect(AppColors.background.toARGB32(), const Color(0xFF0A0A0A).toARGB32());
    });

    test('accent colour is correct', () {
      expect(AppColors.accent.toARGB32(), const Color(0xFF00D4FF).toARGB32());
    });

    test('goldDark colour is correct', () {
      expect(AppColors.goldDark.toARGB32(), const Color(0xFF8B6914).toARGB32());
    });

    test('backgroundGradientMid colour is correct', () {
      expect(AppColors.backgroundGradientMid.toARGB32(), const Color(0xFF0D1B2A).toARGB32());
    });
  });

  group('DiamondApp', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(const DiamondApp());
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows Iconic Studio Pro title on home page', (tester) async {
      await tester.pumpWidget(const DiamondApp());
      expect(find.text('Iconic Studio Pro'), findsOneWidget);
    });

    testWidgets('shows navigation buttons on home page', (tester) async {
      await tester.pumpWidget(const DiamondApp());
      expect(find.text('Marketplace'), findsOneWidget);
      expect(find.text('Studio'),      findsOneWidget);
      expect(find.text('Dashboard'),   findsOneWidget);
    });
  });

  group('IconStudioPro app', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(const IconStudioPro());
      // A frame is enough to confirm no immediate errors.
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows IconStudio header text', (tester) async {
      await tester.pumpWidget(const IconStudioPro());
      expect(find.text('IconStudio'), findsOneWidget);
    });

    testWidgets('shows PRO badge', (tester) async {
      await tester.pumpWidget(const IconStudioPro());
      expect(find.text('PRO'), findsOneWidget);
    });

    testWidgets('header badge shows Free by default', (tester) async {
      await tester.pumpWidget(const IconStudioPro());
      // Default state is unpaid; badge should say Free, not Pro.
      expect(find.text('Free'), findsOneWidget);
      expect(find.text('Pro'),  findsNothing);
    });

    testWidgets('shows Export Icon button', (tester) async {
      await tester.pumpWidget(const IconStudioPro());
      expect(find.text('Export Icon'), findsOneWidget);
    });

    testWidgets('shows upload drop-zone', (tester) async {
      await tester.pumpWidget(const IconStudioPro());
      expect(find.text('Upload your icon'), findsOneWidget);
    });

    testWidgets('shows TRANSFORM section heading', (tester) async {
      await tester.pumpWidget(const IconStudioPro());
      expect(find.text('TRANSFORM'), findsOneWidget);
    });

    testWidgets('shows ADJUSTMENTS section heading', (tester) async {
      await tester.pumpWidget(const IconStudioPro());
      expect(find.text('ADJUSTMENTS'), findsOneWidget);
    });

    testWidgets('shows DIAMOND PHYSICS section heading', (tester) async {
      await tester.pumpWidget(const IconStudioPro());
      expect(find.text('DIAMOND PHYSICS'), findsOneWidget);
    });

    testWidgets('stats bar shows expected labels', (tester) async {
      await tester.pumpWidget(const IconStudioPro());
      expect(find.text('Quality'),  findsOneWidget);
      expect(find.text('Format'),   findsOneWidget);
      expect(find.text('FPS'),      findsOneWidget);
      expect(find.text('Ultra HD'), findsOneWidget);
    });
  });

  group('DiamondPlaceholderPainter', () {
    test('shouldRepaint returns false', () {
      final painter = DiamondPlaceholderPainter();
      expect(painter.shouldRepaint(DiamondPlaceholderPainter()), isFalse);
    });
  });
}
