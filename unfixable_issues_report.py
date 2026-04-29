"""
Iconic Studio Pro – Full Repository Structure & Open Issues Report
==================================================================
Last updated : 2026-04-29

PURPOSE
  This file documents every issue that is currently OPEN (not yet resolved)
  across the codebase, together with the complete repository / file-extension
  structure so it is clear WHERE each problem lives.

  Issues marked [CANNOT FIX WITHOUT EXTERNAL DEPENDENCY] require either a
  third-party service, a payment SDK, or architectural decisions that are
  outside the code itself.

  Issues marked [COMPILE ERROR] prevent the project from building at all.

  Issues marked [OPEN] are code-level bugs or design gaps that can be fixed
  but have not been yet.

Run with:
  python unfixable_issues_report.py
"""

# ─────────────────────────────────────────────────────────────────────────────
#  FULL REPOSITORY STRUCTURE
# ─────────────────────────────────────────────────────────────────────────────

REPO_STRUCTURE = """
iconic_studio_pro/                          ← repository root
│
├── lib/                                    ← ALL Dart source (Flutter app)
│   │
│   ├── main.dart                           ← App entry point & core editor UI
│   │     Extension : .dart
│   │     Classes / Widgets
│   │       • IconStudioPro        – MaterialApp root widget
│   │       • StudioPage           – Stateful editor screen (import counter)
│   │       • _StudioPageState     – Holds EditorState, calls shader & export
│   │       • EditorState          – Immutable value object (copyWith pattern)
│   │       • PreviewCanvas        – Animated GLSL diamond-shader preview circle
│   │       • _PreviewCanvasState  – Ticker, shader uniform configuration
│   │       • PaywallModal         – Upgrade dialog (NON-FUNCTIONAL – see issue #1)
│   │       • _StatItem            – Stats bar item (FPS is hardcoded – see issue #9)
│   │     Key behaviours
│   │       • Image import limited to 2 free uses (bypassed on restart – issue #3)
│   │       • Export via RepaintBoundary → PNG at 3× pixel ratio
│   │       • Responsive: mobile (<600 px) vs desktop layout
│   │
│   ├── auth_screen.dart                    ← Local (SharedPreferences) auth
│   │     Extension : .dart
│   │     Classes
│   │       • AuthState   – ChangeNotifier; sign-up / login / logout; stores
│   │                        hashed password in SharedPreferences
│   │       • AuthGate    – Routes to AuthScreen or the app child
│   │       • AuthScreen  – TabBar: _SignUpForm | _LoginForm
│   │       • _AuthField, _GoldButton – Shared form widgets
│   │     ⚠  Known issue: login checks email only, not password (issue #4)
│   │     ⚠  Completely separate from Firebase Auth in firebase_service.dart
│   │        (dual auth systems never connected – issue #12)
│   │
│   ├── app_colors.dart                     ← AppColors constants
│   │     Extension : .dart
│   │     Constants: background, panel, panelBorder, gold, goldLight,
│   │                textPrimary, textSecondary, uploadZone
│   │     Rule: never use raw Color(0x…) literals in widget code.
│   │
│   ├── export_helper.dart                  ← Conditional-export router
│   │     Extension : .dart
│   │     Selects export_io.dart on native or export_web.dart on web at
│   │     compile time using Dart's 'if (dart.library.html)' syntax.
│   │
│   ├── export_io.dart                      ← Native-platform export
│   │     Extension : .dart
│   │     Android  → getExternalStorageDirectory() / getApplicationDocumentsDirectory()
│   │     iOS      → getApplicationDocumentsDirectory()
│   │     Desktop  → FilePicker.platform.saveFile() native dialog
│   │
│   ├── export_web.dart                     ← Web export
│   │     Extension : .dart
│   │     Uses dart:html Blob + AnchorElement to trigger browser download.
│   │     ⚠  dart:html is deprecated in Dart 3.x (issue #10)
│   │
│   ├── editor_storage.dart                 ← Slider/setting persistence
│   │     Extension : .dart
│   │     Class: EditorStorage (static), SavedEditorData
│   │     Saves all EditorState double fields + importsUsed via SharedPreferences.
│   │
│   ├── firebase_options.dart               ← Firebase platform config
│   │     Extension : .dart
│   │     ⚠  ALL VALUES ARE PLACEHOLDERS ('YOUR_…') – Firebase cannot connect
│   │        (issue #13 – cannot fix without a real Firebase project)
│   │
│   ├── firebase_service.dart               ← Firebase Auth + Firestore + Storage
│   │     Extension : .dart
│   │     Class: FirebaseService (static methods)
│   │       • Auth  : signUp, signIn, signOut, resetPassword
│   │       • Profile : getUserProfile, updateUserProfile, getUserPlan
│   │       • Packs   : createPack, getUserPacks, getMarketplacePacks,
│   │                   updatePack, deletePack
│   │       • Icons   : addIconToPack, getPackIcons, deleteIcon
│   │       • Storage : uploadIconImage, uploadPackThumbnail
│   │       • Imports : getImportsUsed, incrementImports
│   │       • Marketplace: publishPack, recordDownload
│   │     ⚠  Firebase.initializeApp() is NEVER called in main() (issue #6)
│   │     ⚠  _packs is a private getter accessed from pack_editor_screen.dart
│   │        – compile error in Dart (issue #7)
│   │
│   ├── packs_screen.dart                   ← Icon-packs list UI (Firebase-backed)
│   │     Extension : .dart
│   │     Class: PacksScreen (StatelessWidget)
│   │     Shows user's icon packs from Firestore; create / open / publish.
│   │     ⚠  Never navigated to from main.dart – dead/unreachable screen (issue #8)
│   │
│   └── pack_editor_screen.dart             ← Pack editor + icon editor UI
│         Extension : .dart
│         Classes
│           • PackEditorScreen – Displays icons in a pack, publish flow
│           • IconEditorSheet  – Full editor for one icon (embeds StudioPage)
│         ⚠  Calls StudioPage(embeddedMode:, initialState:, onStateChanged:)
│            but StudioPage takes no such parameters – compile error (issue #2)
│         ⚠  Accesses FirebaseService._packs directly – private member
│            cross-file access forbidden in Dart (issue #7)
│
├── shaders/
│   └── diamond_master.frag                 ← GLSL 4.60 fragment shader
│         Extension : .frag
│         Inputs (uniforms): uSize, uTime, uRefractionIndex, uSparkleIntensity,
│           uFacetDepth, uBrightness, uContrast, uSaturation, uBlur,
│           uLightPosition (vec3), uRotation, uScale, uUserImage (sampler2D)
│         Techniques: Voronoi facets, Phong highlight, chromatic dispersion,
│           animated light-ray sparkle, shimmer
│
├── assets/
│   └── icons/                              ← Bundled assets (declared in pubspec)
│         Extension : (none – contains only .gitkeep)
│         ⚠  Empty directory; any asset reference would fail at runtime (issue #11)
│
├── test/
│   └── widget_test.dart                    ← Widget & unit tests
│         Extension : .dart
│         Test groups
│           • App launch smoke         – pumps StudioPage directly
│           • EditorState copyWith     – immutability unit test
│           • Export button presence   – taps Export Icon button
│           • ShaderBuilder mounting   – mounts ShaderBuilder widget
│           • Color API withValues     – checks alpha on AppColors.gold
│           • SharedPreferences path   – asserts main.dart has no SharedPreferences
│         ⚠  Imports dart:io and reads lib/main.dart via relative path (issue #5)
│
├── android/                                ← Android platform project
│   └── (standard Flutter Android scaffold)
│
├── ios/                                    ← iOS platform project
│   └── (standard Flutter iOS scaffold)
│
├── web/                                    ← Flutter web platform files
│   ├── index.html
│   └── manifest.json
│
├── website/                                ← Static marketing / landing page
│   └── (HTML/CSS marketing files – not part of the Flutter app)
│
├── .github/
│   └── workflows/
│       └── ci.yml                          ← GitHub Actions CI pipeline
│             Extension : .yml
│             Steps: flutter analyze –fatal-infos → flutter test →
│                    build Android APK → build iOS → build web
│
├── pubspec.yaml                            ← Flutter package manifest
│     Extension : .yaml
│     Dependencies: flutter_shaders, file_picker, path_provider, crypto,
│       flutter_svg, firebase_core, firebase_auth, cloud_firestore,
│       firebase_storage, shared_preferences
│
├── project_map.py                          ← Earlier repo structure + issue map
├── issues_blocking_go_live.py              ← Earlier issue tracker (18 issues)
├── unfixable_issues_report.py              ← THIS FILE
│
└── deliverables/
    ├── ISSUES_FIXED_REPORT.txt
    └── ISSUES_TO_FIX.md
"""


# ─────────────────────────────────────────────────────────────────────────────
#  ISSUE CATEGORIES
# ─────────────────────────────────────────────────────────────────────────────

COMPILE_ERROR       = "COMPILE ERROR"           # App does not build
CANNOT_FIX_EXTERNAL = "CANNOT FIX – EXTERNAL"   # Requires 3rd-party / config
OPEN                = "OPEN"                     # Fixable code bug / gap


# ─────────────────────────────────────────────────────────────────────────────
#  OPEN ISSUES (unable to be fixed without the work described)
# ─────────────────────────────────────────────────────────────────────────────

ISSUES = [

    # ── Compile Errors ──────────────────────────────────────────────────────

    {
        "id"      : 1,
        "status"  : COMPILE_ERROR,
        "file"    : "lib/pack_editor_screen.dart  lines 535–539",
        "title"   : "StudioPage called with non-existent named parameters",
        "detail"  : (
            "IconEditorSheet builds its body with:\n"
            "  StudioPage(embeddedMode: true, initialState: editorState,\n"
            "             onStateChanged: (s) => setState(...));\n"
            "but the StudioPage constructor (lib/main.dart line 92) is:\n"
            "  const StudioPage({super.key});\n"
            "It accepts no named parameters other than 'key'. Dart will refuse\n"
            "to compile this with:\n"
            "  error: The named parameter 'embeddedMode' isn't defined.\n"
            "  error: The named parameter 'initialState' isn't defined.\n"
            "  error: The named parameter 'onStateChanged' isn't defined.\n"
            "Fix: either add those parameters to StudioPage, or redesign\n"
            "IconEditorSheet so it does not try to embed StudioPage."
        ),
    },
    {
        "id"      : 2,
        "status"  : COMPILE_ERROR,
        "file"    : "lib/pack_editor_screen.dart  lines 470–474",
        "title"   : "FirebaseService._packs private getter accessed cross-file",
        "detail"  : (
            "pack_editor_screen.dart updates an icon with:\n"
            "  await FirebaseService._packs\n"
            "        .doc(widget.packId).collection('icons')...\n"
            "'_packs' is declared as a private static getter in\n"
            "lib/firebase_service.dart:\n"
            "  static CollectionReference get _packs => _db.collection('packs');\n"
            "In Dart, names starting with '_' are private to the LIBRARY (file).\n"
            "Accessing them from another file is a compile error:\n"
            "  error: The getter '_packs' isn't defined for the class 'FirebaseService'.\n"
            "Fix: promote _packs to a public getter, or add a dedicated\n"
            "updateIconInPack() static method to FirebaseService."
        ),
    },

    # ── Cannot Fix Without External Dependency ──────────────────────────────

    {
        "id"      : 3,
        "status"  : CANNOT_FIX_EXTERNAL,
        "file"    : "lib/main.dart  lines 175–190",
        "title"   : "PaywallModal 'Upgrade Now' button does nothing",
        "detail"  : (
            "The onUpgrade callback wired into PaywallModal is:\n"
            "  () { Navigator.pop(context); /* show snack 'coming soon' */ }\n"
            "No payment SDK (RevenueCat, Stripe, in-app purchases, etc.) is\n"
            "integrated. No Pro flag is ever set. No features are gated after\n"
            "upgrade. The paywall is a visual stub only.\n"
            "Cannot fix without: integrating a payment / subscription SDK and\n"
            "defining what 'Pro' actually unlocks in the app."
        ),
    },
    {
        "id"      : 4,
        "status"  : CANNOT_FIX_EXTERNAL,
        "file"    : "lib/firebase_options.dart  lines 27–51",
        "title"   : "All Firebase config values are placeholder strings",
        "detail"  : (
            "Every field in firebase_options.dart reads 'YOUR_WEB_API_KEY',\n"
            "'YOUR_PROJECT_ID', etc. Firebase cannot initialize with these.\n"
            "Any code path that touches Firestore, Firebase Auth, or Firebase\n"
            "Storage will throw at runtime:\n"
            "  [core/no-app] No Firebase App '[DEFAULT]' has been created.\n"
            "Cannot fix without: running 'flutterfire configure' against a real\n"
            "Firebase project and replacing all placeholder values."
        ),
    },
    {
        "id"      : 5,
        "status"  : CANNOT_FIX_EXTERNAL,
        "file"    : "lib/main.dart  line 66  (void main())",
        "title"   : "Firebase.initializeApp() is never called",
        "detail"  : (
            "main() is simply:\n"
            "  void main() => runApp(const IconStudioPro());\n"
            "Neither 'Firebase.initializeApp()' nor 'WidgetsFlutterBinding.\n"
            "ensureInitialized()' are called before runApp. Any Firebase\n"
            "operation (Firestore, Auth, Storage) will crash immediately with:\n"
            "  Unhandled Exception: [core/no-app]\n"
            "Cannot fix without: first resolving issue #4 (real Firebase config)\n"
            "and then adding the standard Firebase boot sequence to main()."
        ),
    },

    # ── Open Code / Design Issues ────────────────────────────────────────────

    {
        "id"      : 6,
        "status"  : OPEN,
        "file"    : "lib/main.dart  lib/auth_screen.dart  lib/firebase_service.dart",
        "title"   : "Two completely separate, disconnected auth systems",
        "detail"  : (
            "The app ships two auth implementations that never talk to each other:\n"
            "  1. SharedPreferences auth (auth_screen.dart / AuthState) – used\n"
            "     by main.dart via AuthGate. Passwords stored locally as SHA-256\n"
            "     hashes. No server involved.\n"
            "  2. Firebase Auth (firebase_service.dart – signUp/signIn/signOut)\n"
            "     – never called from anywhere in the UI.\n"
            "The packs screens (packs_screen.dart, pack_editor_screen.dart) use\n"
            "FirebaseService.currentUser to identify the owner of a pack. Because\n"
            "Firebase Auth is never signed in, currentUser is always null, so\n"
            "every pack/icon would be attributed to ownerId=null.\n"
            "Fix: choose one auth system and delete the other. Given the Firebase\n"
            "packages already declared, migrate to Firebase Auth and remove\n"
            "the SharedPreferences auth entirely."
        ),
    },
    {
        "id"      : 7,
        "status"  : OPEN,
        "file"    : "lib/main.dart  line 86  (AuthGate child)",
        "title"   : "PacksScreen and PackEditorScreen are dead/unreachable code",
        "detail"  : (
            "The navigation tree rooted at main.dart is:\n"
            "  IconStudioPro → AuthGate → StudioPage\n"
            "There is no route, tab, button, or Navigator.push anywhere in\n"
            "main.dart that leads to PacksScreen or PackEditorScreen.\n"
            "These two screens (and the entire Firebase packs/icons system)\n"
            "are completely unreachable by users.\n"
            "Fix: add a navigation entry point to PacksScreen from StudioPage\n"
            "(e.g. an AppBar action, BottomNavigationBar, or Drawer)."
        ),
    },
    {
        "id"      : 8,
        "status"  : OPEN,
        "file"    : "lib/main.dart  _StudioPageState  line 100",
        "title"   : "Free import limit is trivially bypassed by restarting the app",
        "detail"  : (
            "'importsUsed' is an int field on _StudioPageState. Although\n"
            "EditorStorage persists slider values across restarts, it also\n"
            "saves importsUsed (editor_storage.dart line 48), and _loadState\n"
            "restores it (main.dart line 127). However, because the state is\n"
            "loaded asynchronously in initState, there is a window where the\n"
            "counter reads 0 and a race-condition import may slip through.\n"
            "More critically, clearing app data or reinstalling resets it.\n"
            "Fix: gate the import limit server-side (Firebase) so it cannot\n"
            "be bypassed by clearing local storage."
        ),
    },
    {
        "id"      : 9,
        "status"  : OPEN,
        "file"    : "lib/auth_screen.dart  AuthState.login()  lines 56–76",
        "title"   : "Login does not verify the password",
        "detail"  : (
            "AuthState.login() checks:\n"
            "  storedEmail == email  (case-insensitive trim match)\n"
            "but the stored password hash is never compared. Line 67:\n"
            "  if (storedHash.isNotEmpty && storedHash != _hashPassword(password))\n"
            "The condition is 'storedHash.isNotEmpty AND mismatch', so if\n"
            "storedHash IS empty (e.g. a legacy account or cleared prefs), any\n"
            "password grants access. Even with a stored hash the logic is\n"
            "correct, but the guard on empty hash creates a bypass.\n"
            "Fix: throw an exception when storedHash is empty rather than\n"
            "silently logging in."
        ),
    },
    {
        "id"      : 10,
        "status"  : OPEN,
        "file"    : "lib/export_web.dart  line 2",
        "title"   : "dart:html is deprecated in Dart 3.x and will be removed",
        "detail"  : (
            "export_web.dart uses 'import dart:html as html' with:\n"
            "  // ignore: avoid_web_libraries_in_flutter\n"
            "dart:html is deprecated since Dart 3.0. The canonical replacement\n"
            "is 'package:web' + 'dart:js_interop'. The ignore suppresses the\n"
            "lint today, but when dart:html is removed the build will break\n"
            "with no fallback.\n"
            "Fix: rewrite export_web.dart using package:web."
        ),
    },
    {
        "id"      : 11,
        "status"  : OPEN,
        "file"    : "assets/icons/",
        "title"   : "assets/icons/ directory is empty (only .gitkeep)",
        "detail"  : (
            "pubspec.yaml declares 'assets/icons/' as an asset bundle directory.\n"
            "The directory contains only a '.gitkeep' placeholder. Any code\n"
            "that references a specific asset inside this directory (e.g.\n"
            "AssetImage('assets/icons/my_icon.png')) will fail at runtime with\n"
            "a missing-asset FlutterError.\n"
            "Fix: either add the intended icon files, or remove the assets\n"
            "declaration from pubspec.yaml if no bundled icons are needed."
        ),
    },
    {
        "id"      : 12,
        "status"  : OPEN,
        "file"    : "lib/main.dart  PreviewCanvas  upload zone label",
        "title"   : "SVG upload advertised in UI but not actually supported",
        "detail"  : (
            "The upload zone text reads 'PNG or JPG (max. 5 MB)' in the\n"
            "current source, but flutter_svg is a listed dependency and the\n"
            "original design advertised SVG support. FilePicker with\n"
            "FileType.image does not include SVG on most platforms, and\n"
            "Image.memory() cannot decode SVG bytes regardless.\n"
            "Fix: either add flutter_svg rendering for SVG bytes, or keep\n"
            "SVG off the list and don't import flutter_svg (dead dependency)."
        ),
    },
    {
        "id"      : 13,
        "status"  : OPEN,
        "file"    : "lib/main.dart  PaywallModal._buildTier()  line ~692",
        "title"   : "'Cloud sync' advertised in paywall but never implemented",
        "detail"  : (
            "The Pro Monthly tier feature list includes 'Cloud sync'. No sync,\n"
            "backend write, or network API for user icon data exists anywhere\n"
            "in the codebase. Even if the Firebase packs system were wired up\n"
            "correctly, it is only a packs/icons store, not a general cloud-sync\n"
            "of editor state.\n"
            "Fix: implement actual cloud sync of editor state to Firestore,\n"
            "or remove 'Cloud sync' from the feature list."
        ),
    },
    {
        "id"      : 14,
        "status"  : OPEN,
        "file"    : "lib/main.dart  _buildStatsBar()  line ~465",
        "title"   : "Stats bar shows hardcoded fake '120 FPS'",
        "detail"  : (
            "_buildStatsBar returns a Row with a _StatItem whose value is the\n"
            "literal string '120'. This is not a real measurement. On low-end\n"
            "phones or browser tabs the actual frame rate may be much lower,\n"
            "making this a misleading claim visible to all users.\n"
            "Fix: use SchedulerBinding.instance.addTimingsCallback to compute\n"
            "real FPS, or remove the FPS stat entirely."
        ),
    },
    {
        "id"      : 15,
        "status"  : OPEN,
        "file"    : "test/widget_test.dart  lines 1 and 79–91",
        "title"   : "Test reads lib/main.dart via a relative file path",
        "detail"  : (
            "The 'SharedPreferences path key' test group does:\n"
            "  final source = File('lib/main.dart').readAsStringSync();\n"
            "This relative path only resolves correctly when the test runner's\n"
            "working directory is the project root. If tests are ever run from\n"
            "a different directory the test throws FileSystemException and the\n"
            "CI test step fails.\n"
            "Fix: use path.join(Directory.current.path, 'lib', 'main.dart'),\n"
            "or replace with a simple compile-time assertion that does not\n"
            "need to read a source file at runtime."
        ),
    },
]


# ─────────────────────────────────────────────────────────────────────────────
#  RUNNER – print the report
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    compile_errors   = [i for i in ISSUES if i["status"] == COMPILE_ERROR]
    external_blocks  = [i for i in ISSUES if i["status"] == CANNOT_FIX_EXTERNAL]
    open_issues      = [i for i in ISSUES if i["status"] == OPEN]

    W = 72  # line width

    def hr(ch="="):
        print(ch * W)

    def section(title):
        hr()
        print(f"  {title}")
        hr()

    def print_issue(issue):
        tag    = f"[{issue['status']} #{issue['id']}]"
        title  = issue["title"]
        where  = issue["file"]
        detail = issue["detail"]
        print()
        print(f"{tag}  {title}")
        print(f"  Where : {where}")
        for line in detail.splitlines():
            print(f"  {line}")

    # ── Header ────────────────────────────────────────────────────────────────
    hr()
    print("  Iconic Studio Pro")
    print("  Unfixable / Open Issues Report  –  2026-04-29")
    hr()
    print()
    print(f"  Total issues tracked : {len(ISSUES)}")
    print(f"  {COMPILE_ERROR}       : {len(compile_errors)}")
    print(f"  {CANNOT_FIX_EXTERNAL} : {len(external_blocks)}")
    print(f"  {OPEN}                        : {len(open_issues)}")

    # ── Structure ─────────────────────────────────────────────────────────────
    print()
    section("REPOSITORY STRUCTURE")
    print(REPO_STRUCTURE)

    # ── Compile errors ────────────────────────────────────────────────────────
    print()
    hr("-")
    print(f"  {COMPILE_ERROR}S  ({len(compile_errors)})")
    print(f"  App will NOT build until these are resolved.")
    hr("-")
    for issue in compile_errors:
        print_issue(issue)

    # ── External blocks ───────────────────────────────────────────────────────
    print()
    hr("-")
    print(f"  {CANNOT_FIX_EXTERNAL}  ({len(external_blocks)})")
    print(f"  Require a third-party service, paid SDK, or config credentials.")
    hr("-")
    for issue in external_blocks:
        print_issue(issue)

    # ── Open code issues ──────────────────────────────────────────────────────
    print()
    hr("-")
    print(f"  {OPEN} ISSUES  ({len(open_issues)})")
    print(f"  Fixable in code; not yet resolved.")
    hr("-")
    for issue in open_issues:
        print_issue(issue)

    print()
    hr()
    print("  End of report")
    hr()
