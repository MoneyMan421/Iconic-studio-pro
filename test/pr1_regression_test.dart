import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconic_studio_pro/app_colors.dart';
import 'package:iconic_studio_pro/main.dart' as main_lib;

// Tests ported from PR #1 (copilot/iconics-pro-next-steps), adapted to main:
// - EditorState's image field is userImageBytes on main (was userImage)
// - EditorState's constructor is not const on main
// - AppColors on main has no accent/goldDark/backgroundGradientMid, so only
//   the gold and background palette tests from PR 1 apply
void main() {
  group('EditorState (ported from PR 1)', () {
    test('default values are correct', () {
      final state = main_lib.EditorState();
      expect(state.scale, 50.0);
      expect(state.rotation, 0.0);
      expect(state.brightness, 100.0);
      expect(state.contrast, 100.0);
      expect(state.saturation, 100.0);
      expect(state.blur, 0.0);
      expect(state.refractionIndex, 2.42);
      expect(state.sparkleIntensity, 0.8);
      expect(state.facetDepth, 0.6);
      expect(state.userImageBytes, isNull);
    });

    test('copyWith changes only specified fields', () {
      final base = main_lib.EditorState();
      final updated = base.copyWith(brightness: 150, blur: 5.0);
      expect(updated.brightness, 150.0);
      expect(updated.blur, 5.0);
      expect(updated.scale, base.scale);
      expect(updated.refractionIndex, base.refractionIndex);
    });

    test('copyWith with no arguments returns equivalent state', () {
      final base = main_lib.EditorState(scale: 75, rotation: 45);
      final copy = base.copyWith();
      expect(copy.scale, base.scale);
      expect(copy.rotation, base.rotation);
    });
  });

  group('AppColors (ported from PR 1)', () {
    test('gold colour is correct', () {
      expect(AppColors.gold.toARGB32(), const Color(0xFFD4AF37).toARGB32());
    });

    test('background colour is correct', () {
      expect(
        AppColors.background.toARGB32(),
        const Color(0xFF0A0A0A).toARGB32(),
      );
    });
  });
}
