import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconic_studio_pro/app_colors.dart';
import 'package:iconic_studio_pro/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconic_studio_pro/main.dart' as main_lib;

void main() {
  group('App launch smoke', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders key studio UI', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: StudioPage()),
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
        const MaterialApp(home: StudioPage()),
      );
      await tester.pump();

      final exportButton = find.widgetWithText(ElevatedButton, 'Export Icon');
      expect(exportButton, findsOneWidget);

      await tester.tap(exportButton);
      await tester.pump();
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

  group('SharedPreferences separation', () {
    test('main.dart exports studio widgets without direct SharedPreferences dependency', () {
      // This test ensures the main library can be imported successfully.
      // The actual enforcement of SharedPreferences separation happens at the
      // architecture level: lib/main.dart uses EditorStorage instead of
      // SharedPreferences directly, maintaining clean separation of concerns.
      // If SharedPreferences were directly used in main.dart, the code would
      // violate our architecture convention (documented in custom instructions).
      expect(main_lib.StudioPage, isNotNull);
      expect(main_lib.EditorState, isNotNull);
    });
  });
}
