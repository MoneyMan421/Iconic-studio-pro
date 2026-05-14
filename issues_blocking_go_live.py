"""
Iconic Studio Pro – Repository Structure & Known Issues
========================================================
Last updated: 2026-04-27

STATUS KEY
  [FIXED]  Already resolved in the codebase.
  [OPEN]   Still present and needs to be addressed.

Run this file with:  python issues_blocking_go_live.py
"""

# ── Repository structure ─────────────────────────────────────────────────────
REPO_STRUCTURE = """
iconic_studio_pro/                     ← repo root
│
├── lib/                               ← ALL Dart source code
│   ├── main.dart                      ← App entry point, all core UI & editor logic
│   │     • IconStudioPro (MaterialApp root)
│   │     • StudioPage / _StudioPageState (editor screen, import counter)
│   │     • EditorState (immutable value object, copyWith pattern)
│   │     • PreviewCanvas (animated GLSL diamond shader preview)
│   │     • PaywallModal (upgrade dialog – local Pro unlock)
│   │     • _StatItem, _buildStatsBar (live FPS display)
│   ├── auth_screen.dart               ← Auth state & sign-up / sign-in UI
│   │     • AuthState (ChangeNotifier, SharedPreferences persistence)
│   │     • AuthGate (routes to AuthScreen or child based on login state)
│   │     • AuthScreen → _SignUpForm, _LoginForm
│   │     • _AuthField, _GoldButton (shared form widgets)
│   ├── app_colors.dart                ← AppColors constants (never use raw Color literals)
│   ├── export_helper.dart             ← Conditional export: routes to io or web impl
│   ├── export_io.dart                 ← Native export (Android/iOS: documents dir; desktop: save dialog)
│   └── export_web.dart                ← Web export (package:web download helper)
│
├── shaders/
│   └── diamond_master.frag            ← GLSL fragment shader (diamond refraction effect)
│
├── test/
│   └── widget_test.dart               ← Widget & unit tests (pumps StudioPage directly)
│
├── android/                           ← Android platform files
├── ios/                               ← iOS platform files
├── web/                               ← Flutter web platform files (index.html, manifest.json)
│
├── .github/
│   └── workflows/
│       ├── ci.yml                     ← CI: analyze → test → build (Android + iOS + web)
│       └── codeql.yml                 ← CodeQL: Kotlin/Android code scanning
│
├── pubspec.yaml                       ← Dependencies & asset declarations
├── issues_blocking_go_live.py         ← This file – issue tracker
└── deliverables/
    ├── ISSUES_FIXED_REPORT.txt
    └── ISSUES_TO_FIX.md
"""

# ── Issue list ───────────────────────────────────────────────────────────────
FIXED = "FIXED"
OPEN  = "OPEN"

issues = [
    # ── Fixed: CI / test issues ──────────────────────────────────────────────
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
            "download via browser APIs. lib/export_helper.dart selects the correct implementation "
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

    # ── Additional fixes completed after the initial report ───────────────────
    {
        "id": 9,
        "status": FIXED,
        "file": "lib/main.dart – line 128",
        "title": "PAYWALLMODAL 'UPGRADE NOW' BUTTON DOES NOTHING",
        "detail": (
            "The paywall action previously only closed the dialog. "
            "FIXED: the upgrade action now unlocks Pro locally on-device, persists that state, "
            "and enables unlimited imports for the current installation."
        ),
    },
    {
        "id": 10,
        "status": FIXED,
        "file": "lib/main.dart – _StudioPageState line 98",
        "title": "FREE IMPORT LIMIT IS TRIVIALLY BYPASSED",
        "detail": (
            "The import counter used to live only in widget state. "
            "FIXED: import usage is persisted via EditorStorage, and the paywall gate now also "
            "respects persisted Pro unlock state across restarts."
        ),
    },
    {
        "id": 11,
        "status": FIXED,
        "file": "lib/auth_screen.dart – AuthState.login(), lines 39-51",
        "title": "LOGIN REQUIRES NO PASSWORD",
        "detail": (
            "Login previously allowed access without guaranteed password verification. "
            "FIXED: sign-up stores a password hash, login normalizes email comparison, "
            "and missing/corrupt password-hash data is now treated as an error."
        ),
    },
    {
        "id": 12,
        "status": FIXED,
        "file": "lib/main.dart – PreviewCanvas upload zone, line 560",
        "title": "SVG UPLOAD ADVERTISED BUT NOT SUPPORTED",
        "detail": (
            "The upload copy overstated supported formats. "
            "FIXED: the label now matches the actual implementation and only advertises PNG/JPG support."
        ),
    },
    {
        "id": 13,
        "status": FIXED,
        "file": "lib/main.dart – PaywallModal._buildTier(), line 629",
        "title": "'CLOUD SYNC' ADVERTISED IN PAYWALL BUT NEVER IMPLEMENTED",
        "detail": (
            "The paywall previously advertised a nonexistent cloud sync feature. "
            "FIXED: unsupported feature claims were removed from the paywall copy."
        ),
    },
    {
        "id": 14,
        "status": FIXED,
        "file": "pubspec.yaml – dependencies, line 13",
        "title": "`image_picker` PACKAGE DECLARED BUT NEVER USED",
        "detail": (
            "The stale unused dependency noted in the original report is no longer present. "
            "FIXED: pubspec no longer carries the obsolete unused image-picker dependency."
        ),
    },
    {
        "id": 15,
        "status": FIXED,
        "file": "assets/icons/ (contains only .gitkeep)",
        "title": "`assets/icons/` DIRECTORY IS EMPTY",
        "detail": (
            "An empty asset directory was still declared as a bundled asset. "
            "FIXED: the unused asset-bundle declaration and corresponding CI assumption were removed."
        ),
    },
    {
        "id": 16,
        "status": FIXED,
        "file": "lib/main.dart – _buildStatsBar(), line 410",
        "title": "STATS BAR DISPLAYS HARDCODED FAKE '120 FPS'",
        "detail": (
            "The stats bar used a fake constant FPS value. "
            "FIXED: FPS is now derived from frame-timing data and updates on a throttled interval."
        ),
    },
    {
        "id": 17,
        "status": FIXED,
        "file": "lib/export_web.dart – line 2",
        "title": "`dart:html` IS DEPRECATED IN DART 3.x",
        "detail": (
            "Web export relied on deprecated `dart:html`. "
            "FIXED: export_web.dart now uses `package:web` with `dart:js_interop`, removing the deprecated import."
        ),
    },
    {
        "id": 18,
        "status": FIXED,
        "file": "test/widget_test.dart – line 1 & 79",
        "title": "TEST FILE IMPORTS `dart:io` AND READS SOURCE FROM A RELATIVE PATH",
        "detail": (
            "The widget test used a brittle repo-relative file lookup. "
            "FIXED: the test now resolves `package:iconic_studio_pro/main.dart` via package URI before reading the file."
        ),
    },
]


# ── Runner ───────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    open_issues  = [i for i in issues if i["status"] == OPEN]
    fixed_issues = [i for i in issues if i["status"] == FIXED]

    print("=" * 70)
    print("  Iconic Studio Pro")
    print("=" * 70)

    print("\nREPOSITORY STRUCTURE")
    print(REPO_STRUCTURE)

    print("=" * 70)
    print(f"  Issue Tracker  ({len(issues)} total issues)")
    print(f"  {len(open_issues)} OPEN   |   {len(fixed_issues)} FIXED")
    print("=" * 70)

    print(f"\n{'─'*70}")
    print(f"  OPEN ISSUES ({len(open_issues)})")
    print(f"{'─'*70}")
    for issue in open_issues:
        print(f"\n[OPEN #{issue['id']}]  {issue['title']}")
        print(f"  Where: {issue['file']}")
        print(f"  {issue['detail']}")

    print(f"\n{'─'*70}")
    print(f"  FIXED ISSUES ({len(fixed_issues)})")
    print(f"{'─'*70}")
    for issue in fixed_issues:
        print(f"\n[FIXED #{issue['id']}]  {issue['title']}")
        print(f"  Where: {issue['file']}")
        print(f"  {issue['detail']}")

    print(f"\n{'=' * 70}")
