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
        "status": OPEN,
        "title": "NO FLUTTER WEB PLATFORM CONFIGURED",
        "detail": (
            "There is no `web/` directory in the repository. Running `flutter build web` "
            "would fail immediately because the web target has never been initialized "
            "(`flutter create --platforms=web .` has never been run). "
            "The app cannot be deployed as a website without this."
        ),
    },
    {
        "id": 5,
        "status": OPEN,
        "title": "`dart:io` USED THROUGHOUT lib/main.dart – breaks Flutter web",
        "detail": (
            "`import 'dart:io'` is at the top of main.dart and `File`, `Platform`, `Directory` "
            "are used (approx. lines 125, 167-194). These APIs do not exist on Flutter web. "
            "Any web build would compile but crash at runtime the moment a user tries to "
            "pick an image or export an icon."
        ),
    },
    {
        "id": 6,
        "status": OPEN,
        "title": "`EditorState.userImage` IS A `dart:io File` – mobile/desktop only",
        "detail": (
            "The field `File? userImage` (main.dart) and its use with `Image.file()` are "
            "desktop/mobile-only. On web, file_picker returns bytes not a file path, so "
            "`result.files.single.path` would be null and the image would never load."
        ),
    },
    {
        "id": 7,
        "status": OPEN,
        "title": "EXPORT IS BROKEN ON WEB – `FilePicker.saveFile()` unsupported",
        "detail": (
            "`FilePicker.platform.saveFile()` is the export branch for non-Android/iOS, "
            "but `saveFile` is not supported on Flutter web. Attempting to export an icon "
            "on a web deployment would either throw an exception or silently do nothing."
        ),
    },
    {
        "id": 8,
        "status": OPEN,
        "title": "NO CI WEB BUILD STEP",
        "detail": (
            ".github/workflows/ci.yml only builds for Android and iOS. There is no "
            "`flutter build web` step, so web-breaking regressions (like the dart:io "
            "usages above) would never be caught before deployment."
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
        "status": OPEN,
        "title": "FREE IMPORT LIMIT IS TRIVIALLY BYPASSED",
        "detail": (
            "`importsUsed` is stored only in `_StudioPageState` widget state. It resets to 0 "
            "every time the app is restarted. The 2-import paywall gate is bypassed by "
            "simply closing and reopening the app."
        ),
    },
    {
        "id": 11,
        "status": OPEN,
        "title": "LOGIN REQUIRES NO PASSWORD",
        "detail": (
            "`AuthState.login()` (auth_screen.dart) only checks that the supplied email matches "
            "the stored email. No password is verified. If the stored email is empty "
            "(first login ever), *any* email logs straight in. Any user who knows or guesses "
            "a registered email address gains full access."
        ),
    },
    {
        "id": 12,
        "status": OPEN,
        "title": "SVG UPLOAD ADVERTISED BUT NOT SUPPORTED",
        "detail": (
            "The upload zone UI text reads 'PNG, SVG, or JPG (max. 5 MB)', but "
            "`FilePicker.platform.pickFiles(type: FileType.image)` does not include SVG "
            "in its allowed formats. Picking an SVG will either be blocked by the picker "
            "or result in a broken image because `Image.file()` cannot render SVG."
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
        "status": OPEN,
        "title": "`image_picker` PACKAGE DECLARED BUT NEVER USED",
        "detail": (
            "pubspec.yaml lists `image_picker: ^1.0.7` as a dependency, but no Dart file "
            "in the project ever imports or uses it. The app uses `file_picker` instead. "
            "This is dead weight that inflates app size and could cause version-conflict "
            "issues with transitive dependencies."
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
        "status": OPEN,
        "title": "STATS BAR DISPLAYS HARDCODED FAKE '120 FPS'",
        "detail": (
            "The stats bar at the bottom of the studio shows a hard-coded string `'120'` for FPS. "
            "This is not a real measurement. On low-end devices or web, the actual frame rate "
            "could be far lower, making this a misleading claim visible to all users."
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
