"""
Iconic Studio Pro — Full Repository Structure & Issues Report
=============================================================
Generated: 2026-04-29

This file documents:
  1. The complete repository layout (every file and what it does).
  2. Every known OPEN issue — including those NOT yet addressed in
     issues_blocking_go_live.py — across security, architecture,
     compiler correctness, UI/UX honesty, and test reliability.
  3. The 8 issues that have already been FIXED for historical context.

Run with:  python full_issues_report.py
"""

# ── 1. COMPLETE REPOSITORY STRUCTURE ─────────────────────────────────────────

REPO_STRUCTURE = """
iconic_studio_pro/                            ← repo root
│
├── lib/                                      ← ALL Dart source
│   │
│   ├── main.dart                             ← App entry point & entire studio UI
│   │     Classes / widgets in this file:
│   │       • EditorState         – immutable value object (copyWith pattern)
│   │                                fields: scale, rotation, brightness, contrast,
│   │                                        saturation, blur, refractionIndex,
│   │                                        sparkleIntensity, facetDepth,
│   │                                        userImageBytes (Uint8List?)
│   │       • IconStudioPro       – MaterialApp root, wraps StudioPage in AuthGate
│   │       • StudioPage          – StatefulWidget; editor screen
│   │       • _StudioPageState    – holds EditorState + importsUsed counter;
│   │                                calls EditorStorage.load/save; handles
│   │                                image pick, export, paywall
│   │       • PreviewCanvas       – AnimatedWidget that runs the GLSL shader via
│   │                                flutter_shaders/AnimatedSampler; shows
│   │                                upload zone when no image is loaded
│   │       • _PreviewCanvasState – Ticker drives _elapsedSeconds for shader time
│   │       • PaywallModal        – Dialog shown at 2-import limit; "Upgrade Now"
│   │                                button does NOT integrate a payment SDK
│   │       • _StatItem           – tiny column widget (label + value text)
│   │       • _buildStatsBar()    – row of _StatItem; FPS hard-coded to '120'
│   │
│   ├── auth_screen.dart                      ← Local (SharedPreferences) auth
│   │     Classes / widgets in this file:
│   │       • AuthState           – ChangeNotifier; signUp / login / logout;
│   │                                persists isLoggedIn, displayName,
│   │                                userEmail, userPasswordHash via SharedPrefs
│   │       • AuthGate            – StatefulWidget; loads auth state on startup,
│   │                                routes to AuthScreen or child widget
│   │       • _SplashScreen       – shown while AuthState.load() is pending
│   │       • AuthScreen          – TabBar with _SignUpForm / _LoginForm
│   │       • _SignUpForm         – name + email + password + confirm fields
│   │       • _LoginForm          – email + password fields
│   │       • _AuthField          – shared styled TextFormField
│   │       • _GoldButton         – shared ElevatedButton with gold style
│   │
│   ├── app_colors.dart                       ← All color constants (use ONLY these)
│   │     Constants: background, panel, panelBorder, gold, goldLight,
│   │                textPrimary, textSecondary, uploadZone
│   │
│   ├── editor_storage.dart                   ← Persists EditorState via SharedPrefs
│   │     Classes:
│   │       • EditorStorage       – static save() / load() using SharedPreferences
│   │       • SavedEditorData     – typed container returned by load()
│   │     Keys stored: es_scale, es_rotation, es_brightness, es_contrast,
│   │                  es_saturation, es_blur, es_refractionIndex,
│   │                  es_sparkleIntensity, es_facetDepth, es_importsUsed
│   │
│   ├── export_helper.dart                    ← Conditional compile-time export
│   │     Selects export_web.dart on dart.library.html, else export_io.dart
│   │
│   ├── export_io.dart                        ← Native export (Android/iOS/desktop)
│   │     • saveExportedImage()  – mobile: writes to documents dir;
│   │                               desktop: FilePicker.saveFile() dialog
│   │     Imports: dart:io, file_picker, path_provider
│   │
│   ├── export_web.dart                       ← Web export (browser download)
│   │     • saveExportedImage()  – creates dart:html Blob, triggers <a> click
│   │     Imports: dart:html  ← DEPRECATED in Dart 3.x (see ISSUE #17)
│   │
│   ├── firebase_options.dart                 ← Firebase platform config
│   │     All values are PLACEHOLDER strings ('YOUR_*') — see ISSUE #F3
│   │
│   ├── firebase_service.dart                 ← Full Firebase façade (DEAD CODE)
│   │     Static methods for: Auth, Firestore user-profile, icon-packs,
│   │     icons, Storage upload, import counter, marketplace publish/download
│   │     ⚠  Never imported or called from main.dart or auth_screen.dart
│   │     ⚠  Firebase.initializeApp() is never called — see ISSUE #F1
│   │
│   ├── packs_screen.dart                     ← Icon Packs list UI (DEAD CODE)
│   │     • PacksScreen – StreamBuilder on FirebaseService.getUserPacks()
│   │     ⚠  Never navigated to from any reachable screen — see ISSUE #F2
│   │
│   └── pack_editor_screen.dart               ← Pack & icon editor UI (DEAD CODE)
│         • PackEditorScreen  – per-pack icon grid, publish dialog
│         • IconEditorSheet   – embeds StudioPage with params that DO NOT EXIST
│         ⚠  Accesses FirebaseService._packs (private member) — COMPILE ERROR
│         ⚠  Calls StudioPage(embeddedMode:, initialState:, onStateChanged:)
│            but StudioPage has none of those parameters — COMPILE ERROR
│         See ISSUES #F2, #F4, #F5
│
├── shaders/
│   └── diamond_master.frag                   ← GLSL fragment shader
│         Uniforms (15 floats + 1 sampler):
│           uSize.xy, uTime, uRefractionIndex, uSparkleIntensity, uFacetDepth,
│           uBrightness, uContrast, uSaturation, uBlur,
│           uLightPosition.xyz, uRotation, uScale, sampler (image)
│
├── assets/
│   └── icons/
│       └── .gitkeep                          ← placeholder only — see ISSUE #15
│
├── test/
│   └── widget_test.dart                      ← Widget & unit tests
│         Groups: App launch smoke, EditorState copyWith,
│                 Export button presence, ShaderBuilder mounting,
│                 Color API withValues, SharedPreferences path key
│         ⚠  Uses File('lib/main.dart') with relative path — see ISSUE #18
│
├── android/                                  ← Android platform glue
├── ios/                                      ← iOS platform glue
├── web/                                      ← Flutter web bootstrap
│   ├── index.html
│   └── manifest.json
│
├── website/                                  ← Static marketing site (not shipped)
│
├── .github/
│   └── workflows/
│       └── ci.yml                            ← analyze → test → build matrix
│             Jobs: analyze (flutter analyze --fatal-infos)
│                   test   (flutter test --coverage)
│                   build  (android apk-debug / ios no-codesign / web release)
│             ⚠  No firebase_options substitution step — build would fail if
│                Firebase were actually initialized — see ISSUE #F3
│
├── pubspec.yaml                              ← Package manifest
│     Runtime deps: flutter_shaders, file_picker, path_provider, crypto,
│                   flutter_svg, firebase_core, firebase_auth,
│                   cloud_firestore, firebase_storage, shared_preferences
│     Dev deps:     flutter_test
│     Assets:       assets/icons/
│     Shaders:      shaders/diamond_master.frag
│
├── project_map.py                            ← Python dict version of structure
├── issues_blocking_go_live.py                ← Earlier issue tracker (subset)
├── full_issues_report.py                     ← THIS FILE
│
└── deliverables/
    ├── ISSUES_FIXED_REPORT.txt
    └── ISSUES_TO_FIX.md
"""

# ── 2. ISSUE REGISTRY ─────────────────────────────────────────────────────────

FIXED = "FIXED"
OPEN  = "OPEN"

issues = [

    # ════════════════════════════════════════════════════════════════════════
    # PREVIOUSLY FIXED (historical record)
    # ════════════════════════════════════════════════════════════════════════

    {
        "id": 1,
        "status": FIXED,
        "category": "CI / Test",
        "file": "test/widget_test.dart",
        "title": "Tests pumped AuthGate root widget instead of StudioPage directly",
        "detail": (
            "widget_test.dart pumped `IconStudioPro()` which renders AuthGate. "
            "The async SharedPreferences load never finished inside a single pumpWidget "
            "call so the studio page was never shown, causing find.text('Export Icon') to fail. "
            "FIXED: tests now pump `MaterialApp(home: const StudioPage())` directly."
        ),
    },
    {
        "id": 2,
        "status": FIXED,
        "category": "CI / Compile",
        "file": "shaders/lib/main.dart (deleted)",
        "title": "Stray main.dart inside shaders/ caused ~30 analyzer errors",
        "detail": (
            "A stale copy of an old main.dart was committed inside shaders/. "
            "Flutter's analyzer picked it up recursively, producing duplicate-class and "
            "undefined-method errors. FIXED: the file was deleted."
        ),
    },
    {
        "id": 3,
        "status": FIXED,
        "category": "Deprecated API",
        "file": "lib/main.dart, lib/auth_screen.dart",
        "title": "Color.withOpacity() used in multiple places",
        "detail": (
            "withOpacity() was deprecated in Flutter 3.27. "
            "FIXED: all 6 occurrences replaced with withValues(alpha: x)."
        ),
    },
    {
        "id": 4,
        "status": FIXED,
        "category": "Platform Support",
        "file": "web/ (created)",
        "title": "No Flutter web platform directory existed",
        "detail": (
            "There was no web/ directory; `flutter build web` would fail immediately. "
            "FIXED: web/ with index.html and manifest.json now exists."
        ),
    },
    {
        "id": 5,
        "status": FIXED,
        "category": "Platform Support",
        "file": "lib/main.dart",
        "title": "dart:io used throughout main.dart — broke Flutter web",
        "detail": (
            "import 'dart:io' and direct use of File/Platform/Directory were in main.dart. "
            "FIXED: all I/O extracted into export_io.dart (native) and export_web.dart (web), "
            "selected at compile time by export_helper.dart."
        ),
    },
    {
        "id": 6,
        "status": FIXED,
        "category": "Platform Support",
        "file": "lib/main.dart – EditorState",
        "title": "EditorState.userImage was a dart:io File — mobile/desktop only",
        "detail": (
            "File? userImage with Image.file() only works on native platforms. "
            "FIXED: replaced with Uint8List? userImageBytes + Image.memory()."
        ),
    },
    {
        "id": 7,
        "status": FIXED,
        "category": "Platform Support",
        "file": "lib/export_io.dart, lib/export_web.dart, lib/export_helper.dart",
        "title": "Export was broken on web — FilePicker.saveFile() unsupported on web",
        "detail": (
            "FilePicker.platform.saveFile() is not supported on Flutter web. "
            "FIXED: export logic split across export_io.dart / export_web.dart / export_helper.dart."
        ),
    },
    {
        "id": 8,
        "status": FIXED,
        "category": "CI",
        "file": ".github/workflows/ci.yml",
        "title": "No web build step in CI",
        "detail": (
            "ci.yml only built Android and iOS. "
            "FIXED: build matrix now includes `flutter build web --release`."
        ),
    },

    # ════════════════════════════════════════════════════════════════════════
    # OPEN — documented in issues_blocking_go_live.py
    # ════════════════════════════════════════════════════════════════════════

    {
        "id": 9,
        "status": OPEN,
        "category": "Business Logic",
        "file": "lib/main.dart – _showPaywall(), line ~176",
        "title": "PaywallModal 'Upgrade Now' button does nothing",
        "detail": (
            "The onUpgrade callback is `() => Navigator.pop(context)` followed by a "
            "SnackBar saying 'coming soon'. No payment SDK (e.g. in_app_purchase, "
            "RevenueCat) is integrated, no Pro flag is set, and no features are "
            "unlocked. The entire paywall flow is non-functional."
        ),
    },
    {
        "id": 10,
        "status": OPEN,
        "category": "Security / Business Logic",
        "file": "lib/main.dart – _StudioPageState.importsUsed",
        "title": "Free import limit partially persisted but paywall is still bypassed",
        "detail": (
            "importsUsed IS now saved and loaded via EditorStorage (SharedPreferences). "
            "However, because the paywall itself does nothing (see #9), the counter "
            "is academic: a user can simply clear app data or use a different device "
            "to reset it. Without a server-side gate, the limit cannot be enforced."
        ),
    },
    {
        "id": 11,
        "status": OPEN,
        "category": "Security",
        "file": "lib/auth_screen.dart – AuthState.login(), line ~67",
        "title": "Password check can be silently skipped when hash is empty",
        "detail": (
            "The guard is: `if (storedHash.isNotEmpty && storedHash != _hashPassword(password))`. "
            "If storedHash is somehow empty (e.g., the SharedPreferences entry was "
            "individually deleted while isLoggedIn and userEmail remain set), the "
            "password check is bypassed and any password is accepted. "
            "The check should be: `if (storedHash != _hashPassword(password))` "
            "— i.e., always verify, and treat a missing/empty hash as an error."
        ),
    },
    {
        "id": 12,
        "status": OPEN,
        "category": "UI / UX Honesty",
        "file": "lib/main.dart – PreviewCanvas upload zone, line ~621",
        "title": "Upload zone previously advertised SVG but SVG is not supported",
        "detail": (
            "The label was 'PNG, SVG, or JPG'. It now reads 'PNG or JPG' (fixed in UI) "
            "but flutter_svg is still imported in main.dart and listed in pubspec.yaml "
            "despite no SVG rendering code existing anywhere. Either implement SVG "
            "support (using SvgPicture + rasterisation before the shader) or remove "
            "flutter_svg from both main.dart and pubspec.yaml."
        ),
    },
    {
        "id": 13,
        "status": OPEN,
        "category": "UI / UX Honesty",
        "file": "lib/main.dart – PaywallModal._buildTier()",
        "title": "'Cloud sync' listed as a Pro feature but is never implemented",
        "detail": (
            "Both Pro Monthly and Pro Lifetime tiers advertise 'Cloud sync'. "
            "No sync, API, or backend connection of any kind exists in the codebase. "
            "This constitutes a false feature claim to paying users. "
            "Remove 'Cloud sync' from the feature list, or implement it."
        ),
    },
    {
        "id": 14,
        "status": OPEN,
        "category": "Dependencies",
        "file": "pubspec.yaml",
        "title": "flutter_svg listed as dependency but is unused in the running app",
        "detail": (
            "pubspec.yaml includes `flutter_svg: ^2.0.10+1`. main.dart imports it "
            "(`import 'package:flutter_svg/flutter_svg.dart'`), but no SvgPicture "
            "or any flutter_svg widget is rendered. The import and dependency add "
            "compile time and app size without benefit. Remove both."
        ),
    },
    {
        "id": 15,
        "status": OPEN,
        "category": "Assets",
        "file": "assets/icons/ (contains only .gitkeep)",
        "title": "assets/icons/ directory is empty",
        "detail": (
            "pubspec.yaml declares `assets/icons/` as an asset bundle. The directory "
            "contains only a .gitkeep placeholder. Any code referencing a specific "
            "bundled icon path from this directory will throw a missing-asset error "
            "at runtime."
        ),
    },
    {
        "id": 16,
        "status": OPEN,
        "category": "UI / UX Honesty",
        "file": "lib/main.dart – _buildStatsBar()",
        "title": "Stats bar shows hard-coded '120 FPS'",
        "detail": (
            "_StatItem(label: 'FPS', value: '120') is a constant string, not a real "
            "measurement. On web or low-end devices the actual frame rate is far lower. "
            "Use a SchedulerBinding.instance frame-timing listener to display live FPS, "
            "or remove the FPS stat entirely."
        ),
    },
    {
        "id": 17,
        "status": OPEN,
        "category": "Deprecated API",
        "file": "lib/export_web.dart – line 2",
        "title": "dart:html is deprecated in Dart 3.x",
        "detail": (
            "export_web.dart imports `dart:html` with an ignore comment "
            "`// ignore: avoid_web_libraries_in_flutter`. dart:html is scheduled "
            "for removal in a future Dart/Flutter stable release. "
            "The replacement is `package:web` + `dart:js_interop`. "
            "The linter suppress hides this today, but it will become a hard error."
        ),
    },
    {
        "id": 18,
        "status": OPEN,
        "category": "Test Reliability",
        "file": "test/widget_test.dart – line 90",
        "title": "Test reads lib/main.dart via a relative file path",
        "detail": (
            "`File('lib/main.dart').readAsStringSync()` in the 'SharedPreferences path "
            "key' test group only works when the test runner's working directory is the "
            "repo root. Running from a different directory (e.g. inside test/) throws "
            "FileSystemException. Replace with a package-relative approach or "
            "remove the brittle file-read assertion."
        ),
    },

    # ════════════════════════════════════════════════════════════════════════
    # OPEN — newly discovered issues NOT in issues_blocking_go_live.py
    # ════════════════════════════════════════════════════════════════════════

    {
        "id": "F1",
        "status": OPEN,
        "category": "Architecture / Crash",
        "file": "lib/main.dart – main()",
        "title": "Firebase packages in pubspec but Firebase.initializeApp() is NEVER called",
        "detail": (
            "pubspec.yaml lists firebase_core, firebase_auth, cloud_firestore, and "
            "firebase_storage. However, main() is just `runApp(const IconStudioPro())` "
            "with no `await Firebase.initializeApp(...)` call. "
            "If any Firebase API is ever invoked (e.g., if the app somehow routes to "
            "PacksScreen or calls FirebaseService), it will throw:\n"
            "  [core/no-app] No Firebase App '[DEFAULT]' has been created.\n"
            "Either remove all Firebase packages and dead-code files, or add the "
            "required initialization to main() before runApp()."
        ),
    },
    {
        "id": "F2",
        "status": OPEN,
        "category": "Architecture / Dead Code",
        "file": "lib/firebase_service.dart, lib/packs_screen.dart, lib/pack_editor_screen.dart",
        "title": "Three complete feature files are dead code — never imported or reachable",
        "detail": (
            "firebase_service.dart, packs_screen.dart, and pack_editor_screen.dart "
            "are fully written source files (700+ lines combined) that are never "
            "imported or navigated to from any reachable widget in the app. "
            "main.dart's navigation tree is: IconStudioPro → AuthGate → StudioPage. "
            "PacksScreen and PackEditorScreen are not referenced anywhere in that tree. "
            "These files still compile as part of the package and add dead weight. "
            "They should either be wired into the app or removed."
        ),
    },
    {
        "id": "F3",
        "status": OPEN,
        "category": "Configuration / Security",
        "file": "lib/firebase_options.dart",
        "title": "firebase_options.dart contains only placeholder keys — Firebase cannot connect",
        "detail": (
            "Every FirebaseOptions value is a literal placeholder string:\n"
            "  apiKey: 'YOUR_WEB_API_KEY', appId: 'YOUR_WEB_APP_ID', etc.\n"
            "Even if Firebase.initializeApp() were added, the app would fail to "
            "connect to any Firebase project with these values. "
            "The file must be regenerated with real credentials using:\n"
            "  dart pub global activate flutterfire_cli\n"
            "  flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID\n"
            "Additionally, real keys must never be committed to a public repository."
        ),
    },
    {
        "id": "F4",
        "status": OPEN,
        "category": "Compile Error (in dead code)",
        "file": "lib/pack_editor_screen.dart – IconEditorSheet.build(), line ~535",
        "title": "IconEditorSheet instantiates StudioPage with parameters that do not exist",
        "detail": (
            "pack_editor_screen.dart line ~535 constructs:\n"
            "  StudioPage(\n"
            "    embeddedMode: true,\n"
            "    initialState: editorState,\n"
            "    onStateChanged: (s) => setState(() => editorState = s),\n"
            "  )\n"
            "But StudioPage in main.dart only accepts `{super.key}`. "
            "There is no embeddedMode, initialState, or onStateChanged parameter. "
            "This file would produce a compile error if it were ever imported. "
            "It is only accident that it compiles today — Dart only type-checks "
            "files that are transitively imported from main()."
        ),
    },
    {
        "id": "F5",
        "status": OPEN,
        "category": "Compile Error (in dead code)",
        "file": "lib/pack_editor_screen.dart – _IconEditorSheetState._save(), line ~470",
        "title": "pack_editor_screen.dart accesses the private member FirebaseService._packs",
        "detail": (
            "Line ~470 calls `FirebaseService._packs.doc(...).collection('icons')...`. "
            "In Dart, members prefixed with `_` are private to the library in which "
            "they are defined. Accessing `_packs` from pack_editor_screen.dart "
            "(a different library) is a compile-time error. "
            "Expose a public getter in FirebaseService, or move the call inside "
            "FirebaseService itself."
        ),
    },
    {
        "id": "F6",
        "status": OPEN,
        "category": "Architecture / Auth",
        "file": "lib/auth_screen.dart vs lib/firebase_service.dart",
        "title": "Two completely separate and incompatible authentication systems coexist",
        "detail": (
            "The running app uses AuthState (SharedPreferences + SHA-256 hash). "
            "firebase_service.dart implements a full Firebase Auth system "
            "(createUserWithEmailAndPassword, signInWithEmailAndPassword). "
            "There is no bridge between them. A user logged in via AuthState has "
            "FirebaseService.currentUser == null, so every Firestore/Storage call "
            "in FirebaseService would either fail or write to the wrong user document. "
            "A single auth strategy must be chosen and the other removed."
        ),
    },
    {
        "id": "F7",
        "status": OPEN,
        "category": "Security",
        "file": "lib/auth_screen.dart – AuthState",
        "title": "Single-device, single-account limitation by design",
        "detail": (
            "AuthState stores one set of credentials in SharedPreferences on-device. "
            "There is no way to sign in on a second device, recover a forgotten "
            "password (no reset email), or have more than one account per device. "
            "The `signUp()` method explicitly throws if a different email is used:\n"
            "  'An account already exists. Please log in instead.'\n"
            "This is a fundamental architectural limitation of the local-only auth model."
        ),
    },
    {
        "id": "F8",
        "status": OPEN,
        "category": "Data Integrity",
        "file": "lib/firebase_service.dart – deletePack(), lines ~117-124",
        "title": "deletePack() deletes icons one-by-one without a transaction — leaves orphans on failure",
        "detail": (
            "deletePack() iterates over each icon document and deletes them "
            "individually, then deletes the pack document. If the process is "
            "interrupted mid-loop (network drop, app kill), partial icon documents "
            "will remain orphaned in Firestore, never cleaned up. "
            "Use a batched write (WriteBatch) or a Cloud Function triggered on "
            "pack deletion to guarantee atomicity."
        ),
    },
    {
        "id": "F9",
        "status": OPEN,
        "category": "Runtime Error",
        "file": "lib/firebase_service.dart – getMarketplacePacks(), lines ~101-108",
        "title": "getMarketplacePacks() uses two orderBy fields without a composite Firestore index",
        "detail": (
            "The query:\n"
            "  .where('isPublic', isEqualTo: true)\n"
            "  .where('price', isGreaterThan: 0)\n"
            "  .orderBy('price')\n"
            "  .orderBy('downloads', descending: true)\n"
            "requires a composite Firestore index on (isPublic, price, downloads). "
            "Without that index created in the Firebase console, Firestore returns:\n"
            "  [failed-precondition] The query requires an index.\n"
            "No index definition file (firestore.indexes.json) exists in the repo."
        ),
    },
    {
        "id": "F10",
        "status": OPEN,
        "category": "Logic Bug",
        "file": "lib/main.dart – EditorState.copyWith()",
        "title": "EditorState.copyWith() cannot clear userImageBytes back to null",
        "detail": (
            "copyWith() uses the pattern `userImageBytes ?? this.userImageBytes`. "
            "This means it is impossible to reset the uploaded image to null "
            "(to show the placeholder again) through copyWith — passing null is "
            "indistinguishable from 'not provided'. "
            "Add a sentinel parameter (e.g., `bool clearImage = false`) or use "
            "a nullable wrapper type to allow explicit null assignment."
        ),
    },
    {
        "id": "F11",
        "status": OPEN,
        "category": "Dependencies",
        "file": "pubspec.yaml – Firebase section",
        "title": "Four Firebase packages are bundled but the feature they support is unreachable dead code",
        "detail": (
            "firebase_core, firebase_auth, cloud_firestore, and firebase_storage are "
            "in pubspec.yaml. They add significant compile time, final binary size, "
            "and transitive dependency surface — including Google Play Services on "
            "Android. Because the Firebase feature set is entirely dead code today "
            "(firebase_service.dart, packs_screen.dart, pack_editor_screen.dart are "
            "never imported), these four packages should be removed from pubspec.yaml "
            "until the feature is actually wired up and working."
        ),
    },
    {
        "id": "F12",
        "status": OPEN,
        "category": "Security",
        "file": "lib/auth_screen.dart – AuthState.signUp()",
        "title": "Credentials are stored in plaintext-accessible SharedPreferences with no encryption",
        "detail": (
            "The email and SHA-256 password hash are stored in SharedPreferences "
            "(an unencrypted key-value store). On a rooted Android device or "
            "via an ADB backup, these values can be read directly from the "
            "shared_prefs XML file. "
            "For a production app, use flutter_secure_storage or delegate auth to "
            "a proper backend (e.g., Firebase Auth) so credentials are never stored "
            "locally."
        ),
    },
    {
        "id": "F13",
        "status": OPEN,
        "category": "CI",
        "file": ".github/workflows/ci.yml",
        "title": "CI build step re-creates platform folders with flutter create, risking config overwrite",
        "detail": (
            "ci.yml line ~72:\n"
            "  flutter create --platforms=android,ios --project-name iconic_studio_pro .\n"
            "is run before every native build. Running flutter create on an existing "
            "project can silently overwrite platform-specific configuration files "
            "(e.g., AndroidManifest.xml, Info.plist, build.gradle) if those files "
            "are not committed to the repo. Any custom permissions, signing config, "
            "or entitlements would be lost. Commit the platform folders properly or "
            "remove the flutter create step."
        ),
    },
    {
        "id": "F14",
        "status": OPEN,
        "category": "Test Coverage",
        "file": "test/widget_test.dart",
        "title": "No tests cover the auth flow, editor persistence, or export logic",
        "detail": (
            "The test suite has six groups, all focused on main.dart UI widgets and "
            "EditorState immutability. There are zero tests for:\n"
            "  • AuthState.signUp / login / logout\n"
            "  • EditorStorage.save / load round-trip\n"
            "  • saveExportedImage (export_io / export_web)\n"
            "  • PaywallModal rendering or triggering\n"
            "These untested paths contain several of the open bugs listed above."
        ),
    },
]


# ── 3. RUNNER ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    open_issues  = [i for i in issues if i["status"] == OPEN]
    fixed_issues = [i for i in issues if i["status"] == FIXED]

    # Separate the new-discovery open issues (id starts with 'F')
    existing_open = [i for i in open_issues if isinstance(i["id"], int)]
    new_open      = [i for i in open_issues if isinstance(i["id"], str)]

    LINE = "=" * 72
    DASH = "─" * 72

    print(LINE)
    print("  Iconic Studio Pro — Full Issues Report")
    print(LINE)

    print("\nREPOSITORY STRUCTURE")
    print(REPO_STRUCTURE)

    print(LINE)
    print(f"  Issue Summary  ({len(issues)} total)")
    print(f"  {len(open_issues)} OPEN  ({len(existing_open)} known + {len(new_open)} newly discovered)")
    print(f"  {len(fixed_issues)} FIXED")
    print(LINE)

    # ── Open issues (existing) ─────────────────────────────────────────────
    print(f"\n{DASH}")
    print(f"  OPEN ISSUES — previously documented ({len(existing_open)})")
    print(DASH)
    for issue in existing_open:
        print(f"\n[OPEN #{issue['id']}]  [{issue['category']}]  {issue['title']}")
        print(f"  Where:  {issue['file']}")
        print(f"  Detail: {issue['detail']}")

    # ── Open issues (new discoveries) ─────────────────────────────────────
    print(f"\n{DASH}")
    print(f"  OPEN ISSUES — newly discovered, NOT in issues_blocking_go_live.py ({len(new_open)})")
    print(DASH)
    for issue in new_open:
        print(f"\n[OPEN #{issue['id']}]  [{issue['category']}]  {issue['title']}")
        print(f"  Where:  {issue['file']}")
        print(f"  Detail: {issue['detail']}")

    # ── Fixed issues ───────────────────────────────────────────────────────
    print(f"\n{DASH}")
    print(f"  FIXED ISSUES ({len(fixed_issues)})")
    print(DASH)
    for issue in fixed_issues:
        print(f"\n[FIXED #{issue['id']}]  [{issue['category']}]  {issue['title']}")
        print(f"  Where:  {issue['file']}")
        print(f"  Detail: {issue['detail']}")

    print(f"\n{LINE}")
    print(f"  End of report.  {len(open_issues)} open issues require attention.")
    print(LINE)
