"""
Iconic Studio Pro – Known Issues
=================================
Last updated: 2026-04-27

STATUS KEY
  [FIXED]  Already resolved in the codebase.
  [OPEN]   Still present and needs to be addressed.

Run this file with:  python issues_blocking_go_live.py
"""

FIXED = "FIXED"
OPEN  = "OPEN"

issues = [
    # ── Previously identified CI / test issues ──────────────────────────────
    {
        "id": 1,
        "status": FIXED,
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
        "title": "DEPRECATED API – `Color.withOpacity()` used in multiple places",
        "detail": (
            "withOpacity() was deprecated in Flutter 3.27. There were 6 occurrences across "
            "lib/main.dart and lib/auth_screen.dart. "
            "FIXED: all replaced with `withValues(alpha: x)`."
        ),
    },

    # ── Still-open issues ────────────────────────────────────────────────────
    {
        "id": 4,
        "status": FIXED,
        "title": "NO FLUTTER WEB PLATFORM CONFIGURED",
        "detail": (
            "FIXED: The `web/` directory now exists in the repository (contains index.html and "
            "manifest.json). `flutter build web` can be run and CI includes a web build step."
        ),
    },
    {
        "id": 5,
        "status": FIXED,
        "title": "`dart:io` USED THROUGHOUT lib/main.dart – breaks Flutter web",
        "detail": (
            "FIXED: `import 'dart:io'` has been removed from main.dart entirely. Export logic "
            "is now in platform-specific files: lib/export_io.dart (native) and "
            "lib/export_web.dart (web), selected at compile time via lib/export_helper.dart "
            "using a conditional export (`if (dart.library.html)`)."
        ),
    },
    {
        "id": 6,
        "status": FIXED,
        "title": "`EditorState.userImage` IS A `dart:io File` – mobile/desktop only",
        "detail": (
            "FIXED: The field is now `Uint8List? userImageBytes` (main.dart). "
            "FilePicker is called with `withData: true` so bytes are available on all platforms "
            "including web. `Image.memory()` is used instead of `Image.file()`, "
            "which works everywhere."
        ),
    },
    {
        "id": 7,
        "status": FIXED,
        "title": "EXPORT IS BROKEN ON WEB – `FilePicker.saveFile()` unsupported",
        "detail": (
            "FIXED: Export on web is handled by lib/export_web.dart which uses `dart:html` "
            "Blob + AnchorElement to trigger a browser download. Native export is in "
            "lib/export_io.dart. The conditional export in lib/export_helper.dart selects "
            "the correct implementation at compile time."
        ),
    },
    {
        "id": 8,
        "status": FIXED,
        "title": "NO CI WEB BUILD STEP",
        "detail": (
            "FIXED: .github/workflows/ci.yml now includes a web build job "
            "(`flutter build web --release`) in the matrix alongside android and ios."
        ),
    },
    {
        "id": 9,
        "status": OPEN,
        "title": "PAYWALLMODAL 'UPGRADE NOW' BUTTON DOES NOTHING",
        "detail": (
            "The `onUpgrade` callback passed to `PaywallModal` is `() => Navigator.pop(context)`, "
            "which only closes the dialog. No payment is processed, no Pro flag is set, "
            "and no features are unlocked. The paywall is completely non-functional."
        ),
    },
    {
        "id": 10,
        "status": FIXED,
        "title": "FREE IMPORT LIMIT IS TRIVIALLY BYPASSED",
        "detail": (
            "FIXED: `importsUsed` is now tracked inside `AuthState` (lib/auth_screen.dart) and "
            "persisted to SharedPreferences via `incrementImports()`. It survives app restarts. "
            "`StudioPage` receives the `AuthState` instance from `AuthGate` and reads/updates "
            "it directly; a local fallback (`_localImportsUsed`) is used only in tests where "
            "no auth state is injected."
        ),
    },
    {
        "id": 11,
        "status": FIXED,
        "title": "LOGIN REQUIRES NO PASSWORD",
        "detail": (
            "FIXED: `AuthState.signUp()` now accepts a `password` parameter and persists it to "
            "SharedPreferences (key: `userPassword`). `AuthState.login()` now requires both "
            "`email` and `password` and throws if the password does not match the stored value. "
            "The login form (`_LoginForm` in lib/auth_screen.dart) has a password field with "
            "show/hide toggle, matching the sign-up form."
        ),
    },
    {
        "id": 12,
        "status": FIXED,
        "title": "SVG UPLOAD ADVERTISED BUT NOT SUPPORTED",
        "detail": (
            "FIXED: The upload zone hint text in lib/main.dart (`PreviewCanvas`) has been "
            "corrected from 'PNG, SVG, or JPG (max. 5 MB)' to 'PNG or JPG (max. 5 MB)', "
            "matching what `FilePicker` actually accepts."
        ),
    },
    {
        "id": 13,
        "status": OPEN,
        "title": "'CLOUD SYNC' ADVERTISED IN PAYWALL BUT NEVER IMPLEMENTED",
        "detail": (
            "The Pro Monthly and Pro Lifetime tiers list 'Cloud sync' as a feature. "
            "No sync, backend, or API of any kind exists anywhere in the codebase. "
            "Users who upgrade (if payment were real) would not receive this advertised feature."
        ),
    },
    {
        "id": 14,
        "status": FIXED,
        "title": "`image_picker` PACKAGE DECLARED BUT NEVER USED",
        "detail": (
            "FIXED: `image_picker: ^1.0.7` has been removed from pubspec.yaml. "
            "The app uses `file_picker` for all image selection; `image_picker` was dead weight."
        ),
    },
    {
        "id": 15,
        "status": OPEN,
        "title": "`assets/icons/` DIRECTORY IS EMPTY",
        "detail": (
            "The directory only contains a `.gitkeep` placeholder. pubspec.yaml declares "
            "`assets/icons/` as an asset bundle. Any code that references a specific bundled "
            "icon file from this directory would fail at runtime."
        ),
    },
    {
        "id": 16,
        "status": FIXED,
        "title": "STATS BAR DISPLAYS HARDCODED FAKE '120 FPS'",
        "detail": (
            "FIXED: `_StudioPageState` now has a `Ticker` (via `SingleTickerProviderStateMixin`) "
            "that counts frames per second. `_buildStatsBar()` in lib/main.dart displays the "
            "live measured value (`_fps`) instead of the hard-coded string `'120'`."
        ),
    },
]


if __name__ == "__main__":
    open_issues  = [i for i in issues if i["status"] == OPEN]
    fixed_issues = [i for i in issues if i["status"] == FIXED]

    print("=" * 70)
    print(f"  Iconic Studio Pro – Issue Tracker  ({len(issues)} total issues)")
    print(f"  {len(open_issues)} OPEN   |   {len(fixed_issues)} FIXED")
    print("=" * 70)

    print(f"\n{'─'*70}")
    print(f"  OPEN ISSUES ({len(open_issues)})")
    print(f"{'─'*70}")
    for issue in open_issues:
        print(f"\n[OPEN #{issue['id']}]  {issue['title']}")
        print(f"  {issue['detail']}")

    print(f"\n{'─'*70}")
    print(f"  FIXED ISSUES ({len(fixed_issues)})")
    print(f"{'─'*70}")
    for issue in fixed_issues:
        print(f"\n[FIXED #{issue['id']}]  {issue['title']}")
        print(f"  {issue['detail']}")

    print(f"\n{'=' * 70}")
