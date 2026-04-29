"""
Iconic Studio Pro — Full Repository Structure & Issues Unable to Be Fixed
=========================================================================
Generated: 2026-04-29

This file documents:
  1. The complete directory / file structure of the app and every source extension.
  2. Every known open issue — issues that require external work (payment SDK,
     Firebase project setup, significant architectural rewrites) or are
     structurally unfixable without breaking changes.

Run:  python unfixable_issues_report.py
"""

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 1 — COMPLETE REPOSITORY STRUCTURE
# ─────────────────────────────────────────────────────────────────────────────

REPO_STRUCTURE = """
iconic_studio_pro/                          ← repository root
│
├── lib/                                    ← ALL Dart source (.dart)
│   ├── main.dart                           ← App entry + core editor UI
│   │     Classes / widgets:
│   │       • EditorState            — immutable value object (copyWith pattern)
│   │       • IconStudioPro          — MaterialApp root (wraps AuthGate → StudioPage)
│   │       • StudioPage             — editor screen; manages importsUsed counter
│   │       • _StudioPageState       — loads/saves EditorStorage, drives export
│   │       • PreviewCanvas          — animated GLSL diamond-shader preview (Ticker)
│   │       • PaywallModal           — upgrade dialog (non-functional; no payment SDK)
│   │       • _StatItem              — single stat chip (label + value)
│   │
│   ├── auth_screen.dart                    ← Local authentication (SharedPreferences)
│   │     Classes:
│   │       • AuthState              — ChangeNotifier; stores login state locally
│   │       • AuthGate               — routes to AuthScreen or child widget
│   │       • AuthScreen             — TabBar: Sign-Up / Log-In
│   │       • _SignUpForm            — collects name, email, password; SHA-256 hash
│   │       • _LoginForm             — email + password; verifies against stored hash
│   │       • _AuthField             — styled TextFormField used by both forms
│   │       • _GoldButton            — shared submit button
│   │
│   ├── app_colors.dart                     ← AppColors constants (never use raw Color)
│   │     Constants: background, panel, panelBorder, gold, goldLight,
│   │                textPrimary, textSecondary, uploadZone
│   │
│   ├── editor_storage.dart                 ← Persists EditorState + importsUsed
│   │     Classes:
│   │       • EditorStorage          — static save() / load() via SharedPreferences
│   │       • SavedEditorData        — typed return value from load()
│   │
│   ├── export_helper.dart                  ← Conditional export selector
│   │     Exports export_io.dart on native, export_web.dart on web (dart.library.html)
│   │
│   ├── export_io.dart                      ← Native PNG export (.dart, dart:io)
│   │     • saveExportedImage()      — writes to documents dir (mobile) or
│   │                                   shows save dialog (desktop)
│   │
│   ├── export_web.dart                     ← Web PNG download (.dart, dart:html)
│   │     • saveExportedImage()      — creates Blob URL → programmatic <a> click
│   │
│   ├── firebase_options.dart               ← Firebase platform config (PLACEHOLDER)
│   │     • DefaultFirebaseOptions   — all API keys are 'YOUR_*' placeholders;
│   │                                   never configured with a real Firebase project
│   │
│   ├── firebase_service.dart               ← Firebase facade (DEAD CODE — never imported)
│   │     • FirebaseService          — static helpers for Auth, Firestore, Storage
│   │                                   (signUp/signIn/signOut, packs CRUD, icon CRUD,
│   │                                    storage upload, import counter, marketplace)
│   │
│   ├── pack_editor_screen.dart             ← Pack editor UI (DEAD CODE — never imported)
│   │     • PackEditorScreen         — Firestore-backed icon grid for a pack
│   │     • IconEditorSheet          — embeds StudioPage in a Scaffold (BROKEN: uses
│   │                                   StudioPage constructor params that don't exist)
│   │
│   └── packs_screen.dart                   ← Packs list UI (DEAD CODE — never imported)
│         • PacksScreen              — Firestore-backed grid of user's icon packs;
│                                       calls FirebaseService.signOut() for logout
│                                       (incompatible with SharedPreferences auth)
│
├── shaders/
│   └── diamond_master.frag                 ← GLSL fragment shader (.frag, GLSL 460)
│         Uniforms: uSize, uTime, uRefractionIndex, uSparkleIntensity, uFacetDepth,
│                   uBrightness, uContrast, uSaturation, uBlur, uLightPosition,
│                   uRotation, uScale, uUserImage (sampler2D)
│         Features: Voronoi facets, refraction, chromatic dispersion,
│                   sparkle/rays, shimmer, edge glow
│
├── assets/
│   └── icons/                              ← Asset bundle declared in pubspec.yaml
│         (contains only .gitkeep — directory is empty)
│
├── test/
│   └── widget_test.dart                    ← Widget & unit tests (.dart)
│         Tests: App launch smoke, EditorState copyWith, Export button,
│                ShaderBuilder mount, Color.withValues, SharedPreferences key guard
│         Note: imports dart:io and reads lib/main.dart via relative path (fragile)
│
├── android/                                ← Android platform glue (Kotlin / Gradle)
│   ├── app/
│   │   ├── build.gradle
│   │   ├── proguard-rules.pro
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/com/iconicstudio/pro/MainActivity.kt
│   │       └── res/values/styles.xml
│   ├── gradle/wrapper/gradle-wrapper.properties
│   ├── gradle.properties
│   ├── key.properties.example
│   └── settings.gradle
│
├── web/                                    ← Flutter web platform files
│   ├── index.html
│   └── manifest.json
│
├── website/                                ← Static marketing page (HTML only)
│   └── index.html
│
├── .github/
│   └── workflows/
│       └── ci.yml                          ← CI: analyze → test → build matrix
│             Jobs: analyze (flutter analyze --fatal-infos)
│                   test    (flutter test --coverage)
│                   build   (android APK debug, iOS no-codesign, web release)
│
├── deliverables/                           ← Non-shipped tracking documents
│   ├── ISSUES_FIXED_REPORT.txt
│   └── ISSUES_TO_FIX.md
│
├── pubspec.yaml                            ← Dependencies + asset/shader declarations
│     Key deps: flutter_shaders, file_picker, path_provider, crypto, flutter_svg,
│               firebase_core, firebase_auth, cloud_firestore, firebase_storage,
│               shared_preferences
│
├── project_map.py                          ← Python dict snapshot of repo structure
├── issues_blocking_go_live.py             ← Previous issue tracker (8 fixed, 10 open)
└── unfixable_issues_report.py             ← THIS FILE
"""


# ─────────────────────────────────────────────────────────────────────────────
# SECTION 2 — ISSUES UNABLE TO BE FIXED
# (requires external setup, significant architectural rewrite, or
#  third-party integration that does not yet exist in the codebase)
# ─────────────────────────────────────────────────────────────────────────────

CANNOT_FIX = "CANNOT_FIX"   # requires work outside this codebase (payment SDK, etc.)
STRUCTURAL  = "STRUCTURAL"  # fixable in theory, but requires architectural rewrite
DEAD_CODE   = "DEAD_CODE"   # code that can never run and would crash if wired up
DEPRECATED  = "DEPRECATED"  # API removal scheduled; no non-breaking workaround yet

issues = [

    # ── PAYMENT / MONETISATION ────────────────────────────────────────────────

    {
        "id": 1,
        "category": CANNOT_FIX,
        "severity": "CRITICAL",
        "file": "lib/main.dart — PaywallModal, _showPaywall() (~line 128)",
        "title": "PAYWALL 'UPGRADE NOW' BUTTON DOES NOTHING — NO PAYMENT SDK",
        "detail": (
            "PaywallModal.onUpgrade is wired to `() => Navigator.pop(context)` plus a "
            "SnackBar that says 'coming soon'. No payment SDK (RevenueCat, Stripe, "
            "in_app_purchase, etc.) is installed or configured. Tapping 'Upgrade Now' "
            "dismisses the dialog and does not unlock any feature. The Pro flag is never "
            "set anywhere in the codebase. This cannot be fixed without integrating a "
            "real payment provider and server-side receipt validation."
        ),
    },

    # ── FIREBASE SETUP ────────────────────────────────────────────────────────

    {
        "id": 2,
        "category": CANNOT_FIX,
        "severity": "CRITICAL",
        "file": "lib/firebase_options.dart — all platform configs",
        "title": "FIREBASE NOT CONFIGURED — ALL KEYS ARE PLACEHOLDER STRINGS",
        "detail": (
            "Every field in DefaultFirebaseOptions is a literal placeholder: "
            "'YOUR_WEB_API_KEY', 'YOUR_ANDROID_APP_ID', 'YOUR_SENDER_ID', 'YOUR_PROJECT_ID'. "
            "No real Firebase project has been provisioned. Running `flutterfire configure` "
            "against an actual Firebase project is required before any Firebase feature "
            "(auth, Firestore, Storage) can work. This cannot be fixed in code alone."
        ),
    },
    {
        "id": 3,
        "category": STRUCTURAL,
        "severity": "CRITICAL",
        "file": "lib/main.dart — main() function (line 66)",
        "title": "FIREBASE NEVER INITIALIZED — APP WOULD CRASH ON ANY FIREBASE CALL",
        "detail": (
            "pubspec.yaml declares firebase_core, firebase_auth, cloud_firestore, and "
            "firebase_storage. The FirebaseService class calls FirebaseAuth.instance and "
            "FirebaseFirestore.instance directly. However, main() never calls "
            "`await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`. "
            "Any code path that reaches FirebaseService will throw "
            "`[core/no-app] No Firebase App '[DEFAULT]' has been created'. "
            "Fix: add Firebase.initializeApp() to main() after making issue #2 real."
        ),
    },

    # ── DEAD CODE / DISCONNECTED SCREENS ─────────────────────────────────────

    {
        "id": 4,
        "category": DEAD_CODE,
        "severity": "HIGH",
        "file": "lib/firebase_service.dart, lib/pack_editor_screen.dart, lib/packs_screen.dart",
        "title": "THREE SOURCE FILES ARE COMPLETELY DISCONNECTED — NEVER IMPORTED",
        "detail": (
            "firebase_service.dart, pack_editor_screen.dart, and packs_screen.dart are "
            "never imported by main.dart (or any other file that is reachable from main.dart). "
            "They are dead code — they do not compile into the app and are never executed. "
            "Wiring them up would immediately expose multiple compile errors (see issues #5 "
            "and #6) and runtime crashes (issues #2, #3, #7)."
        ),
    },
    {
        "id": 5,
        "category": DEAD_CODE,
        "severity": "HIGH",
        "file": "lib/pack_editor_screen.dart — IconEditorSheet.build() (~line 535)",
        "title": "COMPILE ERROR: IconEditorSheet CALLS StudioPage() WITH NON-EXISTENT PARAMETERS",
        "detail": (
            "IconEditorSheet.build() constructs StudioPage with three named parameters: "
            "  embeddedMode: true, initialState: editorState, onStateChanged: (s) => ... "
            "StudioPage in lib/main.dart only accepts {super.key}. None of these parameters "
            "exist. If this file were imported and compiled, it would fail with: "
            "  'The named parameter embeddedMode isn't defined.' (and likewise for the others). "
            "Fixing this requires adding those parameters to StudioPage, which is an "
            "architectural change to the core widget."
        ),
    },
    {
        "id": 6,
        "category": DEAD_CODE,
        "severity": "HIGH",
        "file": "lib/pack_editor_screen.dart — _IconEditorSheetState._save() (~line 470)",
        "title": "COMPILE ERROR: ACCESSES PRIVATE FIELD FirebaseService._packs",
        "detail": (
            "_save() calls `FirebaseService._packs.doc(...).collection(...).update(...)` "
            "directly. `_packs` is a private static getter in firebase_service.dart "
            "(prefixed with _). Dart does NOT allow access to private members across "
            "library boundaries. This would produce: "
            "  'The getter \\'_packs\\' isn't defined for the class \\'FirebaseService\\'.' "
            "Fix: either make the getter public, or add a dedicated `updateIconInPack()` "
            "static method to FirebaseService."
        ),
    },

    # ── AUTH ARCHITECTURE ─────────────────────────────────────────────────────

    {
        "id": 7,
        "category": STRUCTURAL,
        "severity": "HIGH",
        "file": "lib/auth_screen.dart vs lib/firebase_service.dart / packs_screen.dart",
        "title": "TWO INCOMPATIBLE AUTH SYSTEMS — SharedPreferences vs Firebase Auth",
        "detail": (
            "auth_screen.dart implements a fully local auth system using SharedPreferences "
            "(email + SHA-256 password hash stored on device). firebase_service.dart wraps "
            "Firebase Authentication and Firestore user profiles. packs_screen.dart calls "
            "FirebaseService.signOut() for its logout button. These two systems are "
            "completely disconnected: signing in via AuthScreen does NOT create a Firebase "
            "session, and signing out via FirebaseService does NOT clear the SharedPreferences "
            "session. The app cannot support both simultaneously. One must be chosen and the "
            "other removed — an architectural rewrite of the auth layer."
        ),
    },

    # ── ADVERTISED FEATURES NEVER IMPLEMENTED ────────────────────────────────

    {
        "id": 8,
        "category": CANNOT_FIX,
        "severity": "HIGH",
        "file": "lib/main.dart — PaywallModal._buildTier() (~line 690)",
        "title": "'CLOUD SYNC' ADVERTISED IN PAYWALL — FEATURE DOES NOT EXIST",
        "detail": (
            "Both Pro Monthly ($4.99/mo) and Pro Lifetime ($49.99) tiers list 'Cloud sync' "
            "as a feature. There is no sync, no backend API, no Firestore read/write connected "
            "to the editor. Even if Firebase were configured (issues #2 and #3), no sync "
            "logic exists. Advertising a feature that is never delivered is a legal and "
            "App Store policy risk. Either build the feature or remove it from the copy."
        ),
    },
    {
        "id": 9,
        "category": STRUCTURAL,
        "severity": "MEDIUM",
        "file": "lib/main.dart — PreviewCanvas upload zone (~line 621) / _pickImage()",
        "title": "SVG ADVERTISED IN UPLOAD LABEL BUT CANNOT BE DECODED",
        "detail": (
            "The upload zone label previously said 'PNG, SVG, or JPG' (now changed to "
            "'PNG or JPG' in the latest code). However, flutter_svg is still listed as a "
            "dependency and imported in main.dart (`import 'package:flutter_svg/flutter_svg.dart'`) "
            "but is never actually used to render SVGs anywhere. If SVG support is not planned, "
            "flutter_svg should be removed from pubspec.yaml to reduce bundle size. "
            "If it IS planned, an SVG-to-bytes pipeline must be built (SvgPicture → RenderObject "
            "→ toImage → Uint8List) because Image.memory() cannot decode SVG bytes."
        ),
    },

    # ── DATA / SECURITY ───────────────────────────────────────────────────────

    {
        "id": 10,
        "category": STRUCTURAL,
        "severity": "MEDIUM",
        "file": "lib/auth_screen.dart — AuthState.login() (lines 56-76)",
        "title": "LOGIN BYPASS POSSIBLE WHEN storedPasswordHash IS MISSING",
        "detail": (
            "login() checks: `if (storedHash.isNotEmpty && storedHash != _hashPassword(password))`. "
            "If storedHash is an empty string (e.g. the key was never written, prefs were "
            "cleared, or a migration wiped it), the condition is false and the check is skipped — "
            "allowing login with ANY password for a known email. "
            "Fix: invert the guard — reject login when storedHash is empty rather than allow it."
        ),
    },
    {
        "id": 11,
        "category": STRUCTURAL,
        "severity": "MEDIUM",
        "file": "lib/auth_screen.dart — AuthState.signUp() (lines 36-54)",
        "title": "SINGLE-ACCOUNT DEVICE LIMIT — ONLY ONE USER CAN EVER REGISTER",
        "detail": (
            "signUp() checks: `if (existingEmail.isNotEmpty && existingEmail != email)` and "
            "throws 'An account already exists.' This means once ANY account is registered on "
            "the device, no other email address can ever sign up. Multiple users sharing a "
            "device or a user wanting to switch accounts cannot sign up with a different email. "
            "This is an intentional design choice but is undocumented and surprising."
        ),
    },
    {
        "id": 12,
        "category": STRUCTURAL,
        "severity": "MEDIUM",
        "file": "lib/main.dart — _pickImage() (lines 153-173)",
        "title": "5 MB FILE SIZE LIMIT ADVERTISED BUT NEVER ENFORCED",
        "detail": (
            "The upload zone displays 'max. 5 MB'. _pickImage() calls "
            "FilePicker.platform.pickFiles(type: FileType.image, withData: true) but never "
            "checks the returned file size. A user can upload a 50 MB or 200 MB image; "
            "the bytes will be passed directly to the GLSL shader sampler and could cause "
            "an OOM crash or extreme slowdown. "
            "Fix: add a size check on `result.files.single.size` and reject files over 5 MB."
        ),
    },

    # ── DEPRECATED APIs ────────────────────────────────────────────────────────

    {
        "id": 13,
        "category": DEPRECATED,
        "severity": "MEDIUM",
        "file": "lib/export_web.dart — lines 1-2",
        "title": "`dart:html` IS DEPRECATED IN DART 3.x — WILL BECOME A HARD ERROR",
        "detail": (
            "export_web.dart imports `dart:html` and suppresses the lint with "
            "`// ignore: avoid_web_libraries_in_flutter`. `dart:html` is being removed from "
            "Dart and will be replaced by `package:web` + `dart:js_interop`. "
            "CI currently passes only because the ignore comment suppresses the info diagnostic. "
            "A future Flutter stable channel release will make this a build error. "
            "Fix: rewrite saveExportedImage() using package:web (XFile or AnchorElement "
            "from dart:js_interop)."
        ),
    },

    # ── TESTING ───────────────────────────────────────────────────────────────

    {
        "id": 14,
        "category": STRUCTURAL,
        "severity": "LOW",
        "file": "test/widget_test.dart — lines 1 and 88-93",
        "title": "TEST READS lib/main.dart VIA RELATIVE dart:io PATH — FRAGILE",
        "detail": (
            "The 'SharedPreferences path key' test imports dart:io and calls "
            "`File('lib/main.dart').readAsStringSync()`. This relative path only resolves "
            "correctly when the test runner's working directory is the repo root (i.e., "
            "`flutter test` from the project root). Running from inside the test/ directory "
            "or from a CI step that changes directory will throw FileSystemException. "
            "Fix: use `Platform.script` to build an absolute path, or replace the test "
            "with a simpler static analysis assertion."
        ),
    },

    # ── UI / UX MISINFORMATION ─────────────────────────────────────────────────

    {
        "id": 15,
        "category": STRUCTURAL,
        "severity": "LOW",
        "file": "lib/main.dart — _buildStatsBar() (~line 471)",
        "title": "STATS BAR SHOWS HARDCODED '120' FOR FPS — NOT A REAL MEASUREMENT",
        "detail": (
            "_StatItem(label: 'FPS', value: '120') is a hard-coded constant string. "
            "On low-end Android devices, Chrome, or Safari the real frame rate may be "
            "30–60 FPS or lower. Displaying '120' is factually incorrect and misleading. "
            "Fix: wire up a SchedulerBinding.instance.addPersistentFrameCallback listener "
            "to measure real frame delta times, or remove the FPS stat entirely."
        ),
    },
    {
        "id": 16,
        "category": STRUCTURAL,
        "severity": "LOW",
        "file": "assets/icons/ (contains only .gitkeep)",
        "title": "`assets/icons/` DIRECTORY IS EMPTY — ANY ASSET REFERENCE WILL CRASH",
        "detail": (
            "pubspec.yaml declares `assets: [assets/icons/]` as an asset bundle. "
            "The directory contains only a .gitkeep placeholder — no actual icon files. "
            "Any call to `rootBundle.load('assets/icons/<name>')` or `AssetImage('assets/icons/<name>')` "
            "will throw a FlutterError at runtime ('Unable to load asset'). "
            "No code currently references a specific file in this directory, so there is no "
            "immediate crash — but the declaration is misleading and will cause failures "
            "the moment any icon asset is added to the code without also adding the file."
        ),
    },
]


# ─────────────────────────────────────────────────────────────────────────────
# SECTION 3 — RUNNER / PRETTY PRINTER
# ─────────────────────────────────────────────────────────────────────────────

CATEGORY_LABELS = {
    CANNOT_FIX:  "CANNOT FIX WITHOUT EXTERNAL SETUP",
    STRUCTURAL:  "REQUIRES ARCHITECTURAL / CODE REWRITE",
    DEAD_CODE:   "DEAD CODE — COMPILE ERRORS IF WIRED UP",
    DEPRECATED:  "DEPRECATED API — FUTURE HARD ERROR",
}

SEVERITY_ORDER = {"CRITICAL": 0, "HIGH": 1, "MEDIUM": 2, "LOW": 3}


def _print_separator(char="═", width=72):
    print(char * width)


def _print_issue(issue):
    cat  = CATEGORY_LABELS.get(issue["category"], issue["category"])
    sev  = issue["severity"]
    sev_icon = {"CRITICAL": "🔴", "HIGH": "🟠", "MEDIUM": "🟡", "LOW": "🔵"}.get(sev, "⚪")
    print(f"\n  #{issue['id']:02d}  {sev_icon} [{sev}]  {issue['title']}")
    print(f"       Category : {cat}")
    print(f"       Where    : {issue['file']}")
    # Word-wrap detail at ~68 chars
    words  = issue["detail"].split()
    line   = "       Detail   : "
    indent = " " * len("       Detail   : ")
    for word in words:
        if len(line) + len(word) + 1 > 72:
            print(line)
            line = indent + word
        else:
            line = (line + " " + word).lstrip()
            if line == word:
                line = indent + word
    if line.strip():
        print(line)


if __name__ == "__main__":
    sorted_issues = sorted(issues, key=lambda i: (SEVERITY_ORDER.get(i["severity"], 9), i["id"]))

    _print_separator()
    print("  Iconic Studio Pro")
    print("  Repository Structure & Issues Unable To Be Fixed")
    print(f"  Total open issues: {len(issues)}")
    _print_separator()

    print("\nREPOSITORY STRUCTURE")
    print(REPO_STRUCTURE)

    _print_separator()
    print(f"  OPEN ISSUES BY CATEGORY  ({len(issues)} total)")
    _print_separator()

    for cat_key, cat_label in CATEGORY_LABELS.items():
        group = [i for i in sorted_issues if i["category"] == cat_key]
        if not group:
            continue
        print(f"\n  ── {cat_label} ({len(group)}) ──")
        for issue in group:
            _print_issue(issue)

    _print_separator()
    print("\n  SEVERITY SUMMARY")
    print("  ─────────────────────────────────────────")
    for sev in ("CRITICAL", "HIGH", "MEDIUM", "LOW"):
        count = sum(1 for i in issues if i["severity"] == sev)
        icon  = {"CRITICAL": "🔴", "HIGH": "🟠", "MEDIUM": "🟡", "LOW": "🔵"}[sev]
        print(f"  {icon}  {sev:10s}  {count} issue{'s' if count != 1 else ''}")
    _print_separator()
