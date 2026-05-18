import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconic_studio_pro/app_colors.dart';
import 'package:iconic_studio_pro/auth_screen.dart';
import 'package:iconic_studio_pro/editor_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconic_studio_pro/main.dart';

void main() {
  // ── App launch smoke ────────────────────────────────────────────────────────
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

    testWidgets('Reset to Defaults button is present', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: StudioPage()),
      );
      await tester.pump();

      expect(find.text('Reset to Defaults'), findsOneWidget);
    });
  });

  // ── EditorState ─────────────────────────────────────────────────────────────
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

    test('default EditorState has expected factory values', () {
      final s = EditorState();
      expect(s.scale, 50);
      expect(s.rotation, 0);
      expect(s.brightness, 100);
      expect(s.contrast, 100);
      expect(s.saturation, 100);
      expect(s.blur, 0);
      expect(s.refractionIndex, closeTo(2.42, 0.001));
      expect(s.sparkleIntensity, closeTo(0.8, 0.001));
      expect(s.facetDepth, closeTo(0.6, 0.001));
      expect(s.userImageBytes, isNull);
    });

    test('copyWith preserves userImageBytes when not overridden', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final original = EditorState(userImageBytes: bytes);
      final updated = original.copyWith(scale: 80);

      expect(updated.userImageBytes, same(bytes));
    });

    test('reset pattern: new EditorState preserves image but resets params', () {
      final bytes = Uint8List.fromList([10, 20, 30]);
      final modified = EditorState(
        scale: 99,
        brightness: 150,
        refractionIndex: 1.5,
        userImageBytes: bytes,
      );
      final reset = EditorState(userImageBytes: modified.userImageBytes);

      // Image preserved
      expect(reset.userImageBytes, same(bytes));
      // Params reset to defaults
      expect(reset.scale, 50);
      expect(reset.brightness, 100);
      expect(reset.refractionIndex, closeTo(2.42, 0.001));
    });
  });

  // ── EditorStorage ───────────────────────────────────────────────────────────
  group('EditorStorage save / load round-trip', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('load returns defaults when nothing has been saved', () async {
      final data = await EditorStorage.load();

      expect(data.scale, 50.0);
      expect(data.rotation, 0.0);
      expect(data.brightness, 100.0);
      expect(data.contrast, 100.0);
      expect(data.saturation, 100.0);
      expect(data.blur, 0.0);
      expect(data.refractionIndex, closeTo(2.42, 0.001));
      expect(data.sparkleIntensity, closeTo(0.8, 0.001));
      expect(data.facetDepth, closeTo(0.6, 0.001));
      expect(data.importsUsed, 0);
    });

    test('saved values survive a reload', () async {
      await EditorStorage.save(
        scale: 75.0,
        rotation: -45.0,
        brightness: 120.0,
        contrast: 80.0,
        saturation: 150.0,
        blur: 3.5,
        refractionIndex: 1.9,
        sparkleIntensity: 1.2,
        facetDepth: 0.3,
        importsUsed: 1,
      );

      final data = await EditorStorage.load();

      expect(data.scale, 75.0);
      expect(data.rotation, -45.0);
      expect(data.brightness, 120.0);
      expect(data.contrast, 80.0);
      expect(data.saturation, 150.0);
      expect(data.blur, closeTo(3.5, 0.001));
      expect(data.refractionIndex, closeTo(1.9, 0.001));
      expect(data.sparkleIntensity, closeTo(1.2, 0.001));
      expect(data.facetDepth, closeTo(0.3, 0.001));
      expect(data.importsUsed, 1);
    });

    test('overwriting a value replaces it on the next load', () async {
      await EditorStorage.save(
        scale: 60.0, rotation: 0.0, brightness: 100.0,
        contrast: 100.0, saturation: 100.0, blur: 0.0,
        refractionIndex: 2.42, sparkleIntensity: 0.8,
        facetDepth: 0.6, importsUsed: 0,
      );
      await EditorStorage.save(
        scale: 90.0, rotation: 30.0, brightness: 110.0,
        contrast: 95.0, saturation: 105.0, blur: 1.0,
        refractionIndex: 2.0, sparkleIntensity: 0.5,
        facetDepth: 0.4, importsUsed: 2,
      );

      final data = await EditorStorage.load();
      expect(data.scale, 90.0);
      expect(data.importsUsed, 2);
    });
  });

  // ── Export button ───────────────────────────────────────────────────────────
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

  // ── PaywallModal ────────────────────────────────────────────────────────────
  group('PaywallModal widget', () {
    testWidgets('renders both pricing tiers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaywallModal(onUpgrade: () {}),
          ),
        ),
      );

      expect(find.text('Unlock Pro'), findsOneWidget);
      expect(find.text('Pro Monthly'), findsOneWidget);
      expect(find.text('Pro Lifetime'), findsOneWidget);
    });

    testWidgets('does NOT advertise Cloud sync', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaywallModal(onUpgrade: () {}),
          ),
        ),
      );

      expect(find.text('Cloud sync'), findsNothing);
    });

    testWidgets('Upgrade Now button triggers onUpgrade callback', (tester) async {
      var called = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaywallModal(onUpgrade: () => called = true),
          ),
        ),
      );

      await tester.tap(find.text('Upgrade Now'));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('shows free import limit message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaywallModal(onUpgrade: () {}),
          ),
        ),
      );

      expect(
        find.textContaining('2 free imports'),
        findsOneWidget,
      );
    });
  });

  // ── ShaderBuilder ───────────────────────────────────────────────────────────
  group('ShaderBuilder widget mounting', () {
    testWidgets('ShaderBuilder can be mounted in widget tree', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShaderBuilder(
              assetKey: 'shaders/diamond_master.frag',
              (context, shader, child) => const SizedBox.shrink(),
            ),
          ),
        ),
      );

      expect(find.byType(ShaderBuilder), findsOneWidget);
    });
  });

  // ── Color API guard ──────────────────────────────────────────────────────────
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

  // ── Auth credential checks ──────────────────────────────────────────────────
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

    test('login rejects wrong password', () async {
      const correctPassword = 'CorrectPass1!';
      final hashed = sha256.convert(utf8.encode(correctPassword)).toString();
      SharedPreferences.setMockInitialValues({
        'userEmail': 'user@example.com',
        'displayName': 'User',
        'userPasswordHash': hashed,
      });

      final auth = AuthState();
      await expectLater(
        () => auth.login(email: 'user@example.com', password: 'WrongPass!'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Incorrect password'),
          ),
        ),
      );
    });

    test('login rejects unknown email', () async {
      SharedPreferences.setMockInitialValues({
        'userEmail': 'registered@example.com',
        'displayName': 'User',
        'userPasswordHash': 'somehash',
      });

      final auth = AuthState();
      await expectLater(
        () => auth.login(email: 'unknown@example.com', password: 'pass'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No account found for that email'),
          ),
        ),
      );
    });

    test('login rejects when no account exists at all', () async {
      SharedPreferences.setMockInitialValues({});

      final auth = AuthState();
      await expectLater(
        () => auth.login(email: 'anyone@example.com', password: 'pass'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No account found'),
          ),
        ),
      );
    });

    test('signUp stores credentials and marks user as logged in', () async {
      SharedPreferences.setMockInitialValues({});

      final auth = AuthState();
      await auth.signUp(
        name: 'Alice',
        email: 'alice@example.com',
        password: 'SecurePass1!',
      );

      expect(auth.isLoggedIn, isTrue);
      expect(auth.displayName, 'Alice');
    });

    test('signUp rejects a second account with a different email', () async {
      SharedPreferences.setMockInitialValues({
        'userEmail': 'first@example.com',
        'displayName': 'First',
        'userPasswordHash': 'somehash',
      });

      final auth = AuthState();
      await expectLater(
        () => auth.signUp(
          name: 'Second',
          email: 'second@example.com',
          password: 'Pass1!',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('An account already exists'),
          ),
        ),
      );
    });

    test('logout clears the logged-in flag', () async {
      const password = 'Pass123!';
      final hashed = sha256.convert(utf8.encode(password)).toString();
      SharedPreferences.setMockInitialValues({
        'userEmail': 'user@example.com',
        'displayName': 'User',
        'userPasswordHash': hashed,
        'isLoggedIn': true,
      });

      final auth = AuthState();
      await auth.load();
      expect(auth.isLoggedIn, isTrue);

      await auth.logout();
      expect(auth.isLoggedIn, isFalse);
    });
  });

  // ── SharedPreferences isolation guard ───────────────────────────────────────
  group('SharedPreferences path key', () {
    test('no SharedPreferences key is currently defined in main app source', () {
      final source = File('lib/main.dart').readAsStringSync();
      expect(source.contains('SharedPreferences'), isFalse);
    });
  });
}
