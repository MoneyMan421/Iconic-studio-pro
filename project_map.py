# Iconic Studio Pro – Project Map
# Copy this file to get the full repo structure and issue data as Python dicts.

REPO_STRUCTURE = {
    "root": "iconic_studio_pro/",
    "lib": {
        "main.dart": [
            "IconStudioPro (MaterialApp root)",
            "StudioPage / _StudioPageState (editor screen, import counter)",
            "EditorState (immutable value object, copyWith pattern)",
            "PreviewCanvas (animated GLSL diamond shader preview)",
            "PaywallModal (upgrade dialog – currently non-functional)",
            "_StatItem, _buildStatsBar (hardcoded FPS display)",
        ],
        "auth_screen.dart": [
            "AuthState (ChangeNotifier, SharedPreferences persistence)",
            "AuthGate (routes to AuthScreen or child based on login state)",
            "AuthScreen → _SignUpForm, _LoginForm",
            "_AuthField, _GoldButton (shared form widgets)",
        ],
        "app_colors.dart": "AppColors constants (never use raw Color literals)",
        "export_helper.dart": "Conditional export: routes to io or web impl",
        "export_io.dart": "Native export (Android/iOS: documents dir; desktop: save dialog)",
        "export_web.dart": "Web export (dart:html Blob download)",
    },
    "shaders": {
        "diamond_master.frag": "GLSL fragment shader (diamond refraction effect)",
    },
    "assets": {
        "icons/": "Bundled icon assets (currently empty – .gitkeep only)",
    },
    "test": {
        "widget_test.dart": "Widget & unit tests (pumps StudioPage directly)",
    },
    "platform_dirs": ["android/", "ios/", "web/"],
    ".github/workflows": {
        "ci.yml": "CI: analyze → test → build (Android + iOS + web)",
    },
    "config_files": ["pubspec.yaml", "issues_blocking_go_live.py"],
    "deliverables": ["ISSUES_FIXED_REPORT.txt", "ISSUES_TO_FIX.md"],
}

FIXED = "FIXED"
OPEN  = "OPEN"

ISSUES = [
    # ── FIXED ────────────────────────────────────────────────────────────────
    {
        "id": 1,
        "status": FIXED,
        "file": "test/widget_test.dart",
        "title": "CI TEST FAILURE – tests pumped root app widget (AuthGate) instead of StudioPage",
        "detail": (
            "test/widget_test.dart previously pumped `const IconStudioPro()` (or `const IconicStudioApp()`), "
            "which renders the AuthGate/splash screen instead of the studio UI. "
            "The async SharedPreferences load never completes within a single pumpWidget call, "
            "so the studio page was never shown and `find.text('Export Icon')` / `find.text('IconStudio')` both failed. "
            "FIXED: tests now pump `MaterialApp(home: const StudioPage())` directly."
        ),
    },
    {
        "id": 2,
        "status": FIXED,
        "file": "shaders/lib/main.dart (deleted)",
        "title": "CI COMPILE ERROR – stray `shaders/lib/main.dart` caused ~30 analyzer errors",
        "detail": (
            "A stale copy of an old main.dart was committed inside the shaders/ directory. "
            "Flutter's analyzer recursively picked it up, causing duplicate class names, "
            "cast_to_non_type, undefined_method, and many other errors. "
            "FIXED: the file has been deleted."
        ),
    },
    {
        "id": 3,
        "status": FIXED,
        "file": "lib/main.dart, lib/auth_screen.dart",
        "title": "DEPRECATED API – `Color.withOpacity()` used in multiple places",
        "detail": (
            "withOpacity() was deprecated in Flutter 3.27. There were 6 occurrences across "
            "lib/main.dart and lib/auth_screen.dart. "
            "FIXED: all replaced with `withValues(alpha: x)`."
        ),
    },
    {
        "id": 4,
        "status": FIXED,
        "file": "web/ (created)",
        "title": "NO FLUTTER WEB PLATFORM CONFIGURED",
        "detail": (
            "There was no `web/` directory in the repository. Running `flutter build web` "
            "would fail immediately because the web target had never been initialized. "
            "FIXED: `web/` directory now exists with index.html and manifest.json."
        ),
    },
    {
        "id": 5,
        "status": FIXED,
        "file": "lib/main.dart",
        "title": "`dart:io` USED THROUGHOUT lib/main.dart – would have broken Flutter web",
        "detail": (
            "`import 'dart:io'` and direct use of `File`, `Platform`, `Directory` were present "
            "in main.dart, making web builds compile but crash at runtime. "
            "FIXED: main.dart no longer imports dart:io. All file/platform I/O has been "
            "extracted into lib/export_io.dart (native) and lib/export_web.dart (web), "
            "selected at compile time via the conditional export in lib/export_helper.dart."
        ),
    },
    {
        "id": 6,
        "status": FIXED,
        "file": "lib/main.dart – EditorState",
        "title": "`EditorState.userImage` WAS A `dart:io File` – mobile/desktop only",
        "detail": (
            "The field `File? userImage` and its use with `Image.file()` were desktop/mobile-only. "
            "On web, file_picker returns bytes not a file path, so the image would never load. "
            "FIXED: EditorState now stores `Uint8List? userImageBytes` and the canvas uses "
            "`Image.memory()` which works on all platforms."
        ),
    },
    {
        "id": 7,
        "status": FIXED,
        "file": "lib/export_io.dart, lib/export_web.dart, lib/export_helper.dart",
        "title": "EXPORT WAS BROKEN ON WEB – `FilePicker.saveFile()` unsupported on web",
        "detail": (
            "`FilePicker.platform.saveFile()` is not supported on Flutter web. "
            "FIXED: export logic is now split. lib/export_io.dart handles Android/iOS/desktop "
            "(documents directory or native save dialog). lib/export_web.dart triggers a browser "
            "download via dart:html Blob. lib/export_helper.dart selects the correct implementation "
            "at compile time with a conditional export."
        ),
    },
    {
        "id": 8,
        "status": FIXED,
        "file": ".github/workflows/ci.yml",
        "title": "NO CI WEB BUILD STEP",
        "detail": (
            ".github/workflows/ci.yml previously only built for Android and iOS. "
            "FIXED: ci.yml now has a build matrix that includes `flutter build web --release`, "
            "so web-breaking regressions are caught in CI before deployment."
        ),
    },

    # ── OPEN ─────────────────────────────────────────────────────────────────
    {
        "id": 9,
        "status": OPEN,
        "file": "lib/main.dart – line 128",
        "title": "PAYWALLMODAL 'UPGRADE NOW' BUTTON DOES NOTHING",
        "detail": (
            "The `onUpgrade` callback passed to `PaywallModal` is `() => Navigator.pop(context)`, "
            "which only closes the dialog. No payment SDK is integrated, no Pro flag is set, "
            "and no features are unlocked. The paywall is completely non-functional."
        ),
    },
    {
        "id": 10,
        "status": OPEN,
        "file": "lib/main.dart – _StudioPageState line 98",
        "title": "FREE IMPORT LIMIT IS TRIVIALLY BYPASSED",
        "detail": (
            "`importsUsed` is stored only in `_StudioPageState` widget state (an in-memory int). "
            "It resets to 0 every time the app is restarted. The 2-import paywall gate is "
            "bypassed by simply closing and reopening the app. "
            "Fix: persist `importsUsed` via SharedPreferences (same pattern used in auth_screen.dart)."
        ),
    },
    {
        "id": 11,
        "status": OPEN,
        "file": "lib/auth_screen.dart – AuthState.login(), lines 39-51",
        "title": "LOGIN REQUIRES NO PASSWORD",
        "detail": (
            "`AuthState.login()` only checks that the supplied email matches the stored email. "
            "No password is verified. If the stored email is empty (first login ever), *any* "
            "email logs straight in. Any user who knows or guesses a registered email address "
            "gains full access. The password fields collected at sign-up are never stored or checked."
        ),
    },
    {
        "id": 12,
        "status": OPEN,
        "file": "lib/main.dart – PreviewCanvas upload zone, line 560",
        "title": "SVG UPLOAD ADVERTISED BUT NOT SUPPORTED",
        "detail": (
            "The upload zone UI text reads 'PNG, SVG, or JPG (max. 5 MB)', but "
            "`FilePicker.platform.pickFiles(type: FileType.image)` does not include SVG "
            "in its allowed formats on most platforms. Even if a file were picked, "
            "`Image.memory()` cannot decode SVG bytes. Either remove SVG from the label "
            "or integrate a proper SVG-rendering library (e.g. flutter_svg)."
        ),
    },
    {
        "id": 13,
        "status": OPEN,
        "file": "lib/main.dart – PaywallModal._buildTier(), line 629",
        "title": "'CLOUD SYNC' ADVERTISED IN PAYWALL BUT NEVER IMPLEMENTED",
        "detail": (
            "The Pro Monthly and Pro Lifetime tiers list 'Cloud sync' as a feature. "
            "No sync, backend, or network API of any kind exists anywhere in the codebase. "
            "Users who upgrade (if payment were real) would not receive this advertised feature. "
            "Either implement cloud sync or remove it from the feature list."
        ),
    },
    {
        "id": 14,
        "status": OPEN,
        "file": "pubspec.yaml – dependencies, line 13",
        "title": "`image_picker` PACKAGE DECLARED BUT NEVER USED",
        "detail": (
            "pubspec.yaml lists `image_picker: ^1.0.7` as a dependency, but no Dart file "
            "in the project ever imports or uses it (`grep` confirms zero usages). "
            "The app uses `file_picker` instead. "
            "This is dead weight that inflates app size and could cause version-conflict "
            "issues with transitive dependencies. Remove it from pubspec.yaml."
        ),
    },
    {
        "id": 15,
        "status": OPEN,
        "file": "assets/icons/ (contains only .gitkeep)",
        "title": "`assets/icons/` DIRECTORY IS EMPTY",
        "detail": (
            "The directory only contains a `.gitkeep` placeholder. pubspec.yaml declares "
            "`assets/icons/` as an asset bundle. Any code that references a specific bundled "
            "icon file from this directory would fail at runtime with a missing-asset error."
        ),
    },
    {
        "id": 16,
        "status": OPEN,
        "file": "lib/main.dart – _buildStatsBar(), line 410",
        "title": "STATS BAR DISPLAYS HARDCODED FAKE '120 FPS'",
        "detail": (
            "The stats bar at the bottom of the studio shows the hard-coded string `'120'` for FPS. "
            "This is not a real measurement. On low-end devices or web, the actual frame rate "
            "could be far lower, making this a misleading claim visible to all users. "
            "Fix: use a SchedulerBinding frame-timing listener to display the real FPS, "
            "or remove the FPS stat entirely."
        ),
    },
    {
        "id": 17,
        "status": OPEN,
        "file": "lib/export_web.dart – line 2",
        "title": "`dart:html` IS DEPRECATED IN DART 3.x",
        "detail": (
            "lib/export_web.dart imports `dart:html` and suppresses the lint with "
            "`// ignore: avoid_web_libraries_in_flutter`. `dart:html` is deprecated and "
            "will be removed in a future Dart/Flutter version. "
            "The replacement is `package:web` + `dart:js_interop`. "
            "CI currently passes because the ignore suppresses the info, but this will "
            "become a hard error in a future Flutter stable release."
        ),
    },
    {
        "id": 18,
        "status": OPEN,
        "file": "test/widget_test.dart – line 1 & 79",
        "title": "TEST FILE IMPORTS `dart:io` AND READS SOURCE FROM A RELATIVE PATH",
        "detail": (
            "test/widget_test.dart imports `dart:io` (line 1) and uses "
            "`File('lib/main.dart').readAsStringSync()` (line 79) to assert that "
            "main.dart does not reference SharedPreferences. This test uses a relative "
            "file path that only works if the test is run from the repo root. If run from "
            "a different working directory (e.g. inside the test/ folder) it will throw a "
            "FileSystemException. Use `Platform.script` or a `rootBundle` asset read instead, "
            "or replace the file-reading approach with a simpler assertion."
        ),
    },
]
