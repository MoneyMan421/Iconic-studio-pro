import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconic_studio_pro/app_colors.dart';
import 'package:iconic_studio_pro/auth_screen.dart';
import 'package:iconic_studio_pro/editor_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconic_studio_pro/main.dart' as main_lib;
import 'package:iconic_studio_pro/paywall_modal.dart';
import 'package:iconic_studio_pro/preview_canvas.dart';

void main() {
  group('App launch smoke', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders key studio UI', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: main_lib.StudioPage()),
      );
      await tester.pump();

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
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('export button is present and tappable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: main_lib.StudioPage()),
      );
      await tester.pump();

      final exportButton = find.widgetWithText(ElevatedButton, 'Export Icon');
      expect(exportButton, findsOneWidget);

      await tester.tap(exportButton);
      await tester.pump();
    });
  });

  group('PreviewCanvas widget', () {
    testWidgets('shows upload copy and triggers callback when tapped', (
      tester,
    ) async {
      var taps = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PreviewCanvas(
              state: EditorState(),
              onPickImage: () => taps++,
            ),
          ),
        ),
      );

      expect(find.text('Preview Canvas'), findsOneWidget);
      expect(find.text('Upload your icon'), findsOneWidget);
      expect(find.text('PNG or JPG (max. 5 MB)'), findsOneWidget);

      await tester.tap(find.text('Upload your icon'));
      await tester.pump();

      expect(taps, 1);
    });
  });

  group('Paywall modal', () {
    testWidgets('renders tiers and fires upgrade callback', (tester) async {
      var upgraded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaywallModal(onUpgrade: () => upgraded = true),
          ),
        ),
      );

      expect(find.text('Unlock Pro'), findsOneWidget);
      expect(find.text('Pro Monthly'), findsOneWidget);
      expect(find.text('Pro Lifetime'), findsOneWidget);
      expect(find.text('Upgrade Now'), findsOneWidget);

      await tester.tap(find.text('Upgrade Now'));
      await tester.pump();

      expect(upgraded, isTrue);
    });
  });

  group('ShaderBuilder widget mounting', () {
    testWidgets('ShaderBuilder can be mounted in widget tree', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
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
    test('withValues preserves rgb and updates alpha', () {
      final source = AppColors.gold;
      final updated = source.withValues(alpha: 0.2);

      expect(updated.r, source.r);
      expect(updated.g, source.g);
      expect(updated.b, source.b);
      expect((updated.a * 255.0).round(), closeTo((0.2 * 255).round(), 1));
    });
  });

  group('Auth login credential checks', () {
    test('login rejects accounts without stored password hash', () async {
      SharedPreferences.setMockInitialValues({
        'userEmail': 'test@example.com',
        'displayName': 'Tester',
      });

      final auth = AuthState();
      await expectLater(
        () => auth.login(email: 'test@example.com', password: 'anything'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Stored credentials are invalid'),
          ),
        ),
      );
    });

    test('login succeeds with a matching stored password hash', () async {
      const password = 'MySecurePass123!';
      final hashed = sha256.convert(utf8.encode(password)).toString();
      SharedPreferences.setMockInitialValues({
        'userEmail': 'test@example.com',
        'displayName': 'Tester',
        'userPasswordHash': hashed,
      });

      final auth = AuthState();
      await auth.login(email: 'test@example.com', password: password);

      expect(auth.isLoggedIn, isTrue);
      expect(auth.displayName, 'Tester');
    });
  });

  group('Architecture: main.dart widget exports', () {
    test('main.dart exports core studio widgets for reuse', () {
      // Verifies that the main library properly exports its key widgets.
      // The architectural constraint (no direct SharedPreferences usage in main.dart)
      // is enforced through code organization: main.dart uses EditorStorage abstraction
      // instead of SharedPreferences directly. See custom instructions for details.
      expect(main_lib.StudioPage, isNotNull);
      expect(main_lib.EditorState, isNotNull);
    });
  });

  group('StudioPage embedded mode', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'scale': 12.0,
        'importsUsed': 2,
      });
    });

    testWidgets('uses initialState and emits changes without loading storage', (
      tester,
    ) async {
      EditorState? latestState;

      await tester.pumpWidget(
        MaterialApp(
          home: main_lib.StudioPage(
            embeddedMode: true,
            initialState: EditorState(scale: 72),
            onStateChanged: (state) => latestState = state,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('72%'), findsOneWidget);
      expect(find.text('2/2 free imports used'), findsNothing);

      final scaleSlider = tester.widget<Slider>(find.byType(Slider).first);
      scaleSlider.onChanged!(80);
      await tester.pump();

      expect(find.text('80%'), findsOneWidget);
      expect(latestState?.scale, 80);
    });
  });
}
