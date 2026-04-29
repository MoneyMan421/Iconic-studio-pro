"""
Iconic Studio Pro — Full Repository Audit Report
=================================================
Generated: 2026-04-29

PURPOSE
  This file is a single, self-contained audit of:
    1. The complete repository structure (every directory & file explained).
    2. ALL open issues — including issues that CANNOT be fixed without
       significant external work (real payment SDK, live Firebase project,
       backend infrastructure, etc.).
    3. A short notes section on issues that were previously tracked but are
       now resolved or whose tracker entry was stale/inaccurate.

Run with:  python repo_audit_report.py
"""

# ══════════════════════════════════════════════════════════════════════════════
#  SECTION 1 — COMPLETE REPOSITORY STRUCTURE
# ══════════════════════════════════════════════════════════════════════════════

REPO_STRUCTURE = """
iconic_studio_pro/                        ← repository root
│
├── lib/                                  ← ALL Dart/Flutter source code
│   │
│   ├── main.dart                         ← App entry-point & entire editor UI
│   │     Classes / widgets:
│   │       • EditorState          — immutable value object (copyWith pattern);
│   │                                 holds all slider values + userImageBytes
│   │       • IconStudioPro        — MaterialApp root; wraps AuthGate → StudioPage
│   │       • StudioPage           — stateful editor screen
│   │       • _StudioPageState     — manages editorState, importsUsed, export,
│   │                                 calls EditorStorage for persistence
│   │       • PreviewCanvas        — animated 300 × 300 GLSL diamond preview;
│   │                                 hosts upload zone
│   │       • _PreviewCanvasState  — runs a Ticker for uTime; calls _configureShader
│   │       • PaywallModal         — upgrade dialog (non-functional; no payment SDK)
│   │       • _StatItem            — tiny column widget used in the stats bar
│   │     Key imports: flutter_shaders, file_picker, flutter_svg (unused),
│   │                  app_colors, auth_screen, editor_storage, export_helper
│   │
│   ├── auth_screen.dart                  ← Local (SharedPreferences) auth
│   │     Classes:
│   │       • AuthState            — ChangeNotifier; load/signUp/login/logout;
│   │                                 passwords are SHA-256 hashed via `crypto`
│   │       • AuthGate             — routes to AuthScreen OR child widget
│   │       • _SplashScreen        — shown while AuthState.load() is awaited
│   │       • AuthScreen           — Tab bar with Sign Up and Log In tabs
│   │       • _SignUpForm          — collects name, email, password, confirm
│   │       • _LoginForm           — collects email + password
│   │       • _AuthField           — shared TextFormField widget
│   │       • _GoldButton          — shared ElevatedButton widget
│   │     Key imports: shared_preferences, crypto, app_colors
│   │
│   ├── app_colors.dart                   ← Centralised colour constants
│   │     • AppColors — static const Color fields only; no raw Color literals
│   │       anywhere else in lib/
│   │
│   ├── editor_storage.dart               ← Persistent editor-state storage
│   │     • EditorStorage  — static load()/save() via SharedPreferences
│   │     • SavedEditorData — typed DTO returned by EditorStorage.load()
│   │     Key imports: shared_preferences
│   │
│   ├── export_helper.dart                ← Compile-time conditional export
│   │     Single line:
│   │       export 'export_io.dart' if (dart.library.html) 'export_web.dart';
│   │     (selected automatically by the Dart compiler per target platform)
│   │
│   ├── export_io.dart                    ← Native (Android / iOS / desktop) export
│   │     • saveExportedImage()  — writes PNG bytes to documents dir (mobile) or
│   │                              shows a native save-file dialog (desktop)
│   │     Key imports: dart:io, file_picker, path_provider
│   │
│   ├── export_web.dart                   ← Web export (browser download)
│   │     • saveExportedImage()  — creates a Blob URL + <a download> click
│   │     Key imports: dart:html (deprecated in Dart 3 — see OPEN issue #17)
│   │
│   ├── firebase_options.dart             ← STUB — placeholder Firebase config
│   │     Contains hard-coded placeholder strings: 'YOUR_WEB_API_KEY' etc.
│   │     The file header instructs the developer to run `flutterfire configure`
│   │     to generate real values. This has NEVER been done.
│   │     ⚠ Firebase is NEVER initialised anywhere in main.dart.
│   │
│   ├── firebase_service.dart             ← Firebase service layer (DEAD CODE)
│   │     • FirebaseService — static methods for FirebaseAuth, Firestore,
│   │                         FirebaseStorage (sign-up, sign-in, icon packs,
│   │                         marketplace, upload, download counter …)
│   │     ⚠ Never imported by main.dart or auth_screen.dart.
│   │     ⚠ Firebase is never initialised — calling any method crashes.
│   │
│   ├── packs_screen.dart                 ← Icon Packs screen (DEAD CODE)
│   │     • PacksScreen — GridView of user packs backed by Firestore stream
│   │     ⚠ Never navigated to from main.dart.
│   │     ⚠ Depends on FirebaseService (which is itself dead).
│   │
│   └── pack_editor_screen.dart           ← Pack editor screen (DEAD CODE)
│         • PackEditorScreen  — shows icons inside a pack, allows publish
│         • IconEditorSheet   — embeds StudioPage inside a pack context
│         ⚠ Never navigated to except from PacksScreen (also dead).
│         ⚠ Depends on FirebaseService.
│
├── shaders/
│   └── diamond_master.frag               ← GLSL 460 fragment shader
│         Uniforms (in declaration order, matching Dart setFloat calls):
│           uSize, uTime, uRefractionIndex, uSparkleIntensity, uFacetDepth,
│           uBrightness, uContrast, uSaturation, uBlur, uLightPosition,
│           uRotation, uScale, uUserImage (sampler2D)
│         Effects: Voronoi facet normals → refraction offset → chromatic
│           dispersion → facet highlight → sparkle rays → shimmer over time
│
├── assets/
│   └── icons/                            ← Declared in pubspec.yaml as asset dir
│         Contents: only .gitkeep (empty directory)
│         ⚠ No actual icon assets — any code referencing a named bundled icon
│           from this path would crash with a missing-asset error at runtime.
│
├── test/
│   └── widget_test.dart                  ← Widget & unit tests
│         Test groups:
│           • 'App launch smoke'           — pumps MaterialApp(home: StudioPage())
│           • 'EditorState immutability'   — unit-tests copyWith
│           • 'Export button presence'     — taps Export Icon button
│           • 'ShaderBuilder mounting'     — mounts ShaderBuilder widget
│           • 'Color API withValues guard' — tests withValues(alpha:)
│           • 'SharedPreferences path key' — reads lib/main.dart as a File
│               ⚠ Uses a relative path (OPEN issue #18)
│
├── android/                              ← Android platform project
│   (re-generated by CI via `flutter create --platforms=android,ios …`)
│
├── ios/                                  ← iOS platform project
│   (re-generated by CI via `flutter create --platforms=android,ios …`)
│
├── web/                                  ← Flutter web platform files
│   ├── index.html                        ← Flutter web bootstrap
│   └── manifest.json                     ← PWA manifest
│
├── website/                              ← Static marketing website (not Flutter)
│   (HTML/CSS landing page; NOT bundled into the app)
│
├── .github/
│   └── workflows/
│       └── ci.yml                        ← GitHub Actions CI pipeline
│             Jobs: analyze → test → build (matrix: android / ios / web)
│             flutter analyze --fatal-infos  (zero-tolerance for infos)
│             flutter test --coverage
│             flutter build apk --debug
│             flutter build ios --debug --no-codesign
│             flutter build web --release
│
├── pubspec.yaml                          ← Package manifest
│     Runtime deps:
│       flutter_shaders ^0.1.2, file_picker ^6.1.1, path_provider ^2.1.3,
│       crypto ^3.0.3, flutter_svg ^2.0.10+1, firebase_core ^2.32.0,
│       firebase_auth ^4.20.0, cloud_firestore ^4.17.5,
│       firebase_storage ^11.7.7, shared_preferences ^2.2.3
│     Assets: assets/icons/
│     Shaders: shaders/diamond_master.frag
│
├── issues_blocking_go_live.py            ← Earlier issue tracker (18 issues)
├── project_map.py                        ← Dict-form repo map + same 18 issues
├── repo_audit_report.py                  ← THIS FILE — full audit (run to print)
│
└── deliverables/
    ├── ISSUES_FIXED_REPORT.txt           ← Narrative of already-resolved issues
    └── ISSUES_TO_FIX.md                  ← Markdown checklist of open issues
"""

# ══════════════════════════════════════════════════════════════════════════════
#  SECTION 2 — ISSUE DEFINITIONS
# ══════════════════════════════════════════════════════════════════════════════

OPEN  = "OPEN"
FIXED = "FIXED"

issues = [

    # ──────────────────────────────────────────────────────────────────────────
    # CRITICAL — Cannot be fixed without external infrastructure / credentials
    # ──────────────────────────────────────────────────────────────────────────

    {
        "id": 1,
        "status": OPEN,
        "severity": "CRITICAL",
        "fixable_without_external_work": False,
        "file": "lib/firebase_options.dart",
        "title": "FIREBASE NEVER CONFIGURED — placeholder stub values throughout",
        "detail": (
            "firebase_options.dart contains hard-coded placeholder strings "
            "('YOUR_WEB_API_KEY', 'YOUR_WEB_APP_ID', 'YOUR_SENDER_ID', etc.) "
            "for every platform (web, Android, iOS). The file header explicitly "
            "says to run `flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID` "
            "to generate real values, but this has never been done. "
            "Additionally, main.dart never calls `await Firebase.initializeApp()`, "
            "so Firebase is completely inert at runtime. "
            "CANNOT BE FIXED without: (a) creating a real Firebase project, "
            "(b) running `flutterfire configure`, and (c) adding initializeApp() "
            "to main()."
        ),
    },
    {
        "id": 2,
        "status": OPEN,
        "severity": "CRITICAL",
        "fixable_without_external_work": False,
        "file": (
            "lib/firebase_service.dart, lib/packs_screen.dart, "
            "lib/pack_editor_screen.dart"
        ),
        "title": "FIREBASE FEATURE LAYER IS DEAD CODE — never wired into the app",
        "detail": (
            "Three entire source files implement a Firebase-backed feature layer "
            "(FirebaseService, PacksScreen, PackEditorScreen) but are never imported "
            "by main.dart or any other file that is reachable from the app entry point. "
            "No navigation exists that reaches PacksScreen or PackEditorScreen. "
            "Even if these files were wired in, Firebase is uninitialized (see issue #1) "
            "so every method in FirebaseService would throw a StateError at runtime. "
            "CANNOT BE FIXED without: a live Firebase project, real credentials, "
            "and intentional UI integration work."
        ),
    },
    {
        "id": 3,
        "status": OPEN,
        "severity": "CRITICAL",
        "fixable_without_external_work": False,
        "file": "lib/main.dart – PaywallModal, line ~180",
        "title": "PAYWALL 'UPGRADE NOW' BUTTON DOES NOTHING — no payment SDK integrated",
        "detail": (
            "The `onUpgrade` callback passed to PaywallModal is: "
            "`() { Navigator.pop(context); ScaffoldMessenger…showSnackBar('Pro upgrade coming soon!'); }` "
            "No payment SDK (RevenueCat, Stripe, in-app purchase, etc.) is integrated. "
            "No Pro flag is ever set to true. No features are unlocked after tapping "
            "'Upgrade Now'. The entire paywall is decorative. "
            "CANNOT BE FIXED without: integrating a real payment/subscription SDK, "
            "a backend to verify receipt tokens, and actual Pro feature gating."
        ),
    },
    {
        "id": 4,
        "status": OPEN,
        "severity": "CRITICAL",
        "fixable_without_external_work": False,
        "file": "lib/main.dart – PaywallModal._buildTier(), line ~690",
        "title": "'CLOUD SYNC' ADVERTISED IN PAYWALL BUT DOES NOT EXIST",
        "detail": (
            "The Pro Monthly tier lists 'Cloud sync' as a paid feature. "
            "No sync, no backend, no network API exists anywhere in the codebase. "
            "Even the Firebase feature layer that COULD power sync is dead code "
            "(see issue #2). Users who purchased (if payment were real) would be "
            "deceived — this is false advertising. "
            "CANNOT BE FIXED without: a functioning Firebase/backend integration, "
            "OR removing 'Cloud sync' from the feature list entirely."
        ),
    },

    # ──────────────────────────────────────────────────────────────────────────
    # HIGH — Broken features, security issues, deprecated APIs
    # ──────────────────────────────────────────────────────────────────────────

    {
        "id": 5,
        "status": OPEN,
        "severity": "HIGH",
        "fixable_without_external_work": True,
        "file": "lib/auth_screen.dart – AuthState.login(), line 67",
        "title": "LOGIN PASSWORD CHECK BYPASSED WHEN storedHash IS EMPTY",
        "detail": (
            "AuthState.login() guards password verification with: "
            "`if (storedHash.isNotEmpty && storedHash != _hashPassword(password))`. "
            "If `userPasswordHash` is absent from SharedPreferences (e.g. the device "
            "was upgraded from an older build that never stored the hash, or prefs were "
            "partially cleared), storedHash is '' — and the condition short-circuits, "
            "letting ANY password through for that account. "
            "FIX: change the guard to "
            "`if (storedHash.isEmpty || storedHash != _hashPassword(password))` so "
            "a missing hash FAILS authentication rather than allowing it."
        ),
    },
    {
        "id": 6,
        "status": OPEN,
        "severity": "HIGH",
        "fixable_without_external_work": True,
        "file": "lib/export_web.dart – line 2",
        "title": "`dart:html` IS DEPRECATED IN DART 3 — will become a hard error",
        "detail": (
            "lib/export_web.dart imports `dart:html` and silences the lint with "
            "`// ignore: avoid_web_libraries_in_flutter`. `dart:html` is deprecated "
            "in Dart 3.x and will be REMOVED in a future Flutter stable release. "
            "CI currently passes only because the lint ignore suppresses the info-level "
            "warning; `--fatal-infos` does not catch it at the suppress site. "
            "The replacement API is `package:web` + `dart:js_interop`. "
            "FIX: migrate export_web.dart to use `package:web` (add `web: ^1.0.0` "
            "to pubspec.yaml and rewrite the Blob/anchor logic)."
        ),
    },
    {
        "id": 7,
        "status": OPEN,
        "severity": "HIGH",
        "fixable_without_external_work": True,
        "file": "lib/main.dart – line 10",
        "title": "`flutter_svg` IMPORTED IN main.dart BUT NEVER USED",
        "detail": (
            "`import 'package:flutter_svg/flutter_svg.dart'` is present at line 10 "
            "of main.dart, but no SVG widget or function from that package is "
            "referenced anywhere in the file. "
            "`flutter analyze --fatal-infos` will fail on this unused import. "
            "FIX: remove the import line from main.dart. "
            "(The flutter_svg package entry in pubspec.yaml may also be removed "
            "if it is not needed elsewhere.)"
        ),
    },

    # ──────────────────────────────────────────────────────────────────────────
    # MEDIUM — Misleading UI, reliability issues
    # ──────────────────────────────────────────────────────────────────────────

    {
        "id": 8,
        "status": OPEN,
        "severity": "MEDIUM",
        "fixable_without_external_work": True,
        "file": "lib/main.dart – _buildStatsBar(), line ~471",
        "title": "STATS BAR SHOWS HARDCODED FAKE '120 FPS'",
        "detail": (
            "The bottom stats bar hard-codes the string '120' as the FPS value. "
            "This is not a live measurement. On low-end Android phones or Flutter Web "
            "the real frame rate may be 30-60 fps, making this actively misleading "
            "to users. "
            "FIX: use a SchedulerBinding.instance.addTimingsCallback listener to "
            "compute the rolling average frame time and display real FPS, "
            "or remove the FPS stat entirely."
        ),
    },
    {
        "id": 9,
        "status": OPEN,
        "severity": "MEDIUM",
        "fixable_without_external_work": True,
        "file": "lib/main.dart – PreviewCanvas upload zone, line ~622",
        "title": "SVG MENTIONED AS SUPPORTED BUT `flutter_svg` IS NOT WIRED IN",
        "detail": (
            "Although the UI label was changed from 'PNG, SVG, or JPG' to 'PNG or JPG', "
            "`import 'package:flutter_svg/flutter_svg.dart'` still exists in main.dart "
            "and is never called. Even if SVG were re-added to the label, "
            "`FilePicker(type: FileType.image)` does not reliably include SVG on most "
            "platforms, and `Image.memory()` cannot decode SVG bytes regardless. "
            "FIX: either (a) remove the flutter_svg import and the package from "
            "pubspec.yaml entirely, or (b) add explicit SVG-file handling using "
            "SvgPicture.memory() from flutter_svg."
        ),
    },
    {
        "id": 10,
        "status": OPEN,
        "severity": "MEDIUM",
        "fixable_without_external_work": True,
        "file": "assets/icons/ (contains only .gitkeep)",
        "title": "`assets/icons/` DIRECTORY IS EMPTY",
        "detail": (
            "pubspec.yaml declares `assets/icons/` as a Flutter asset bundle, but the "
            "directory contains only a `.gitkeep` placeholder. Any code that tries to "
            "load a specific bundled icon from this directory will throw a "
            "FlutterError('Unable to load asset') at runtime. "
            "FIX: populate the directory with the intended icon assets, "
            "OR remove the `assets/icons/` entry from pubspec.yaml if bundled icons "
            "are not required."
        ),
    },

    # ──────────────────────────────────────────────────────────────────────────
    # LOW — Test reliability, stale tracker entries
    # ──────────────────────────────────────────────────────────────────────────

    {
        "id": 11,
        "status": OPEN,
        "severity": "LOW",
        "fixable_without_external_work": True,
        "file": "test/widget_test.dart – line 1 & 90",
        "title": "TEST READS lib/main.dart VIA A RELATIVE `dart:io` File PATH",
        "detail": (
            "test/widget_test.dart imports `dart:io` (line 1) and the last test group "
            "('SharedPreferences path key') calls `File('lib/main.dart').readAsStringSync()` "
            "at line 90. This relative path only resolves correctly when `flutter test` "
            "is run from the repository root. If the working directory differs "
            "(e.g. a CI runner that cd's into test/) a FileSystemException is thrown "
            "and the test suite fails. "
            "FIX: replace the file-read assertion with a source-level check "
            "(e.g. grep the raw string in a simpler assertion), or use "
            "Platform.script to build an absolute path."
        ),
    },

    # ──────────────────────────────────────────────────────────────────────────
    # STRUCTURAL NOTE — Firebase packages inflate build with zero runtime benefit
    # ──────────────────────────────────────────────────────────────────────────

    {
        "id": 12,
        "status": OPEN,
        "severity": "MEDIUM",
        "fixable_without_external_work": True,
        "file": "pubspec.yaml – dependencies",
        "title": "FOUR FIREBASE PACKAGES DECLARED — all dead weight (Firebase uninitialized)",
        "detail": (
            "pubspec.yaml lists firebase_core, firebase_auth, cloud_firestore, "
            "and firebase_storage as runtime dependencies. Because Firebase is never "
            "initialised in main() and firebase_options.dart contains only stubs, "
            "these packages contribute nothing to the running app while inflating "
            "compiled app size and build times significantly. "
            "FIX: either (a) fully set up Firebase (see issue #1 and #2) so the "
            "packages are actually used, or (b) remove all four Firebase packages "
            "from pubspec.yaml and delete firebase_service.dart, packs_screen.dart, "
            "pack_editor_screen.dart, and firebase_options.dart."
        ),
    },
]


# ══════════════════════════════════════════════════════════════════════════════
#  SECTION 3 — STALE / ALREADY-RESOLVED TRACKER ENTRIES
# ══════════════════════════════════════════════════════════════════════════════

STALE_NOTES = """
The following entries appear in the earlier tracker (issues_blocking_go_live.py)
but are either fixed or inaccurate as of the current codebase:

  • Old #1  (CI test pumped AuthGate instead of StudioPage) — FIXED.
            Tests now pump MaterialApp(home: StudioPage()) directly.

  • Old #2  (stray shaders/lib/main.dart) — FIXED. File deleted.

  • Old #3  (Color.withOpacity() deprecated calls) — FIXED. All replaced with
            withValues(alpha: x).

  • Old #4  (no web/ directory) — FIXED. web/index.html + manifest.json exist.

  • Old #5  (dart:io in main.dart) — FIXED. Export logic extracted to
            export_io.dart / export_web.dart.

  • Old #6  (EditorState.userImage was dart:io File) — FIXED. Now Uint8List.

  • Old #7  (FilePicker.saveFile() broken on web) — FIXED. Conditional export.

  • Old #8  (no CI web build step) — FIXED. ci.yml includes web build matrix.

  • Old #10 (free import limit bypassed by restart) — RESOLVED. importsUsed
            is now persisted via EditorStorage / SharedPreferences (es_importsUsed
            key). The tracker entry is stale.

  • Old #11 (login requires no password) — PARTIALLY fixed. Password is now
            SHA-256 hashed on sign-up and verified on login. However the bypass
            for accounts with an EMPTY storedHash still exists (see new issue #5).

  • Old #12 (SVG in upload zone label) — PARTIALLY fixed. The label now reads
            'PNG or JPG' (SVG removed), but flutter_svg is still imported and
            unused (see new issue #7 and #9).

  • Old #14 (image_picker in pubspec.yaml) — STALE. image_picker does NOT appear
            in the current pubspec.yaml. This entry was either resolved already
            or was never accurate.
"""


# ══════════════════════════════════════════════════════════════════════════════
#  RUNNER
# ══════════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    open_issues      = [i for i in issues if i["status"] == OPEN]
    cannot_fix       = [i for i in open_issues if not i["fixable_without_external_work"]]
    can_fix_in_code  = [i for i in open_issues if i["fixable_without_external_work"]]

    by_severity = {"CRITICAL": [], "HIGH": [], "MEDIUM": [], "LOW": []}
    for issue in open_issues:
        by_severity[issue["severity"]].append(issue)

    W = 74

    def bar(char="═"):
        return char * W

    def header(text, char="═"):
        return f"\n{bar(char)}\n  {text}\n{bar(char)}"

    print(header("Iconic Studio Pro — Full Repository Audit Report"))

    print(header("REPOSITORY STRUCTURE", "─"))
    print(REPO_STRUCTURE)

    print(header(f"OPEN ISSUES SUMMARY  ({len(open_issues)} total)"))
    print(f"  {'CRITICAL':<12} {len(by_severity['CRITICAL'])} issues  — "
          "Cannot be fixed without external infrastructure / credentials")
    print(f"  {'HIGH':<12} {len(by_severity['HIGH'])} issues  — "
          "Broken features, deprecated APIs, security")
    print(f"  {'MEDIUM':<12} {len(by_severity['MEDIUM'])} issues  — "
          "Misleading UI, reliability, dead dependencies")
    print(f"  {'LOW':<12} {len(by_severity['LOW'])} issues  — "
          "Test fragility, minor code quality")
    print(f"\n  Fixable with code changes only : {len(can_fix_in_code)}")
    print(f"  Require external work to fix   : {len(cannot_fix)}")

    for sev in ("CRITICAL", "HIGH", "MEDIUM", "LOW"):
        group = by_severity[sev]
        if not group:
            continue
        print(header(f"[{sev}] ISSUES ({len(group)})", "─"))
        for issue in group:
            flag = "⚠ NEEDS EXTERNAL WORK" if not issue["fixable_without_external_work"] else "✓ fixable in code"
            print(f"\n  Issue #{issue['id']:02d}  [{flag}]")
            print(f"  Title : {issue['title']}")
            print(f"  Where : {issue['file']}")
            # Word-wrap detail at ~70 chars
            words = issue["detail"].split()
            line, lines = "  ", []
            for w in words:
                if len(line) + len(w) + 1 > 74:
                    lines.append(line)
                    line = "  " + w + " "
                else:
                    line += w + " "
            if line.strip():
                lines.append(line)
            print("  Detail:")
            print("\n".join(lines))

    print(header("STALE / RESOLVED ENTRIES FROM EARLIER TRACKER", "─"))
    print(STALE_NOTES)

    print(bar())
    print("  End of Iconic Studio Pro Audit Report")
    print(bar())
