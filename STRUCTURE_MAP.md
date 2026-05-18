# Iconic Studio Pro — Construction Structure Map

Lookup key: `struc_map_file`

> **How to read this file:**  Every "layer" is a floor of the building.
> Higher layer numbers sit on top of lower ones — they depend on them but not the other way around.
> Update this file whenever you add, rename, or remove a class, screen, or service.
>
> Last updated: 2026-05-15

---

## Layer 0 — App Boot

```
main()
  └── runApp(IconStudioPro)
```

---

## Layer 1 — App Shell (`lib/main.dart`)

```
IconStudioPro  [StatelessWidget]
  └── MaterialApp
        ├── theme: ThemeData.dark  (gold SliderTheme)
        └── home: AuthGate(child: StudioPage())
```

---

## Layer 2 — Auth Gate (`lib/auth_screen.dart`)

```
AuthGate  [StatefulWidget]
  ├── holds: AuthState (ChangeNotifier)
  ├── while loading  → _SplashScreen   (diamond spinner)
  ├── logged out     → AuthScreen
  └── logged in      → StudioPage      (passes through)
```

---

## Layer 3-A — Auth System (`lib/auth_screen.dart`)

```
AuthState  [ChangeNotifier]
  ├── fields : _isLoggedIn, _displayName
  ├── load()       — reads SharedPreferences on startup
  ├── signUp()     — SHA-256 hashes password, writes prefs
  ├── login()      — validates email + hash
  └── logout()     — clears isLoggedIn flag

AuthScreen  [StatefulWidget]
  └── TabBarView (2 tabs)
        ├── Tab 0: _SignUpForm  → AuthState.signUp()
        └── Tab 1: _LoginForm  → AuthState.login()

Shared sub-widgets
  ├── _AuthField  — styled TextFormField
  └── _GoldButton — gold ElevatedButton with loading spinner
```

---

## Layer 3-B — Data Model (`lib/main.dart`)

```
EditorState  [immutable value object]
  ├── scale, rotation
  ├── brightness, contrast, saturation, blur
  ├── refractionIndex, sparkleIntensity, facetDepth
  ├── userImageBytes (Uint8List?)
  └── copyWith()  — always returns a new copy, never mutates
```

---

## Layer 4 — Main Editor (`lib/main.dart`)

```
StudioPage  [StatefulWidget]
  ├── params : embeddedMode (bool), initialState?, onStateChanged?
  │
  ├── _StudioPageState
  │     ├── editorState : EditorState
  │     ├── importsUsed : int  (free limit = 2)
  │     │
  │     ├── initState()
  │     │     ├── embeddedMode = true  → use initialState, skip storage
  │     │     └── embeddedMode = false → _loadState() from EditorStorage
  │     │
  │     ├── _loadState()      — EditorStorage.load() → setState
  │     ├── _saveState()      — EditorStorage.save() (skipped in embedded)
  │     ├── _setEditorState() — setState + onStateChanged?.call() + _saveState()
  │     │
  │     ├── _pickImage()      — FilePicker → editorState.copyWith(userImageBytes)
  │     │     └── if over free limit → _showPaywall()
  │     │
  │     ├── _exportIcon()     — RenderRepaintBoundary.toImage(3×)
  │     │     └── saveExportedImage() [export_helper.dart]
  │     │
  │     └── build()
  │           └── LayoutBuilder → isMobile (<600px)?
  │                 ├── _buildMobileLayout()   — vertical scroll
  │                 └── _buildDesktopLayout()  — side panel + canvas
  │
  ├── Builder widgets
  │     ├── _buildHeader()        — "IconStudio PRO" + Premium badge
  │     ├── _buildControls()      — 3 groups of sliders + Reset button
  │     │     ├── TRANSFORM       : Scale, Rotation
  │     │     ├── ADJUSTMENTS     : Brightness, Contrast, Saturation, Blur
  │     │     ├── DIAMOND PHYSICS : Refraction, Sparkle, Facet Depth
  │     │     └── _buildResetButton() — resets params to defaults, keeps image
  │     ├── _buildSlider()        — label + Slider + value chip
  │     ├── _buildExportButton()  — "Export Icon" ElevatedButton
  │     ├── _buildStatsBar()      — Ultra HD / PNG / 120 FPS
  │     └── _buildSection()       — section label text
  │
  ├── PreviewCanvas  [StatefulWidget]
  │     ├── Ticker (_elapsedSeconds) — drives live sparkle animation
  │     ├── no image  → _buildPlaceholder()  (ghost diamond)
  │     └── has image →
  │           ShaderBuilder('shaders/diamond_master.frag')
  │             └── AnimatedSampler
  │                   └── _configureShader()  ← maps 15 GLSL uniforms
  │                         uSize, uTime, uRefractionIndex,
  │                         uSparkleIntensity, uFacetDepth,
  │                         uBrightness, uContrast, uSaturation,
  │                         uBlur, uLightPosition xyz,
  │                         uRotation, uScale, image sampler
  │
  └── PaywallModal  [StatelessWidget]
        ├── Pro Monthly  $4.99/mo  — Unlimited imports, Early shader access, Priority support
        └── Pro Lifetime $49.99   — Everything in Pro, Pay once keep forever
        └── onUpgrade callback → _showProComingSoonDialog() (honest "not yet available" message)
```

---

## Layer 5 — Persistence (`lib/editor_storage.dart`)

```
EditorStorage  [static-only utility]
  ├── save(scale, rotation, brightness, contrast, saturation,
  │        blur, refractionIndex, sparkleIntensity, facetDepth,
  │        importsUsed)
  │     └── SharedPreferences — 10 keys written in parallel
  └── load()
        └── returns SavedEditorData  (typed struct with defaults)

SavedEditorData  [plain Dart class]
  └── 10 final fields matching EditorStorage keys
```

---

## Layer 6 — Export Pipeline

```
lib/export_helper.dart
  └── conditional re-export:
        ├── native (Android / iOS / desktop) → export_io.dart
        └── web                              → export_web.dart

lib/export_io.dart
  └── saveExportedImage(name, bytes)
        ├── Android  → getExternalStorageDirectory() or getApplicationDocumentsDirectory()
        ├── iOS      → getApplicationDocumentsDirectory()
        └── Desktop  → FilePicker.platform.saveFile() dialog

lib/export_web.dart
  └── saveExportedImage(name, bytes)
        └── html.Blob → AnchorElement.click() → browser download
```

---

## Layer 7 — Firebase Backend (`lib/firebase_service.dart`)

```
FirebaseService  [static-only singleton, private constructor]
  │
  ├── AUTH
  │     ├── currentUser, uid, authStateChanges (stream)
  │     ├── signUp()      — createUserWithEmailAndPassword + Firestore user doc
  │     ├── signIn()      — signInWithEmailAndPassword
  │     ├── signOut()
  │     └── resetPassword()
  │
  ├── USER PROFILE   (Firestore: /users/{uid})
  │     ├── getUserProfile()
  │     ├── updateUserProfile()
  │     └── getUserPlan()   → 'free' | 'pro'
  │
  ├── ICON PACKS   (Firestore: /packs/{packId})
  │     ├── createPack()
  │     ├── getUserPacks()        — stream, filtered by ownerId
  │     ├── getMarketplacePacks() — stream, public + price > 0
  │     ├── updatePack()
  │     └── deletePack()          — cascades to subcollection /icons
  │
  ├── ICONS   (Firestore: /packs/{packId}/icons/{iconId})
  │     ├── addIconToPack()   — adds doc + increments iconCount
  │     ├── getPackIcons()    — stream, ordered by createdAt
  │     ├── updateIcon()      ← PUBLIC API (used by pack_editor_screen.dart)
  │     └── deleteIcon()      — removes doc + decrements iconCount
  │
  ├── STORAGE   (Firebase Storage: icons/{uid}/{packId}/{iconId}.png)
  │     ├── uploadIconImage()
  │     └── uploadPackThumbnail()
  │
  ├── IMPORT COUNTER
  │     ├── getImportsUsed()
  │     └── incrementImports()
  │
  └── MARKETPLACE
        ├── publishPack()     — isPublic=true + price
        └── recordDownload()  — increments downloads
```

---

## Layer 8 — Packs UI (`lib/packs_screen.dart`, `lib/pack_editor_screen.dart`)

```
PacksScreen  [StatelessWidget]
  ├── AppBar: "My Icon Packs" + logout
  ├── StreamBuilder → FirebaseService.getUserPacks()
  │     └── GridView (2 cols)
  │           ├── pack cards → tap → PackEditorScreen
  │           └── "New Pack" card → _createPack() dialog
  └── FAB: "New Pack"

PackEditorScreen  [StatefulWidget]
  ├── params : packId, packData
  ├── AppBar : pack name + Publish / LIVE badge
  ├── stats bar : icon count, downloads
  ├── StreamBuilder → FirebaseService.getPackIcons()
  │     └── GridView (3 cols)
  │           ├── icon cards → tap       → IconEditorSheet (edit)
  │           │             → long press → _confirmDelete()
  │           └── "Add" card → IconEditorSheet (new)
  └── FAB: +

IconEditorSheet  [StatefulWidget]
  ├── params : packId, iconId?, existingData?
  ├── AppBar : name TextField + Save button
  └── body   : StudioPage(embeddedMode: true,
                          initialState: editorState,
                          onStateChanged: setState)
                 ← StudioPage reused here; no storage load/save
```

---

## Layer 9 — GLSL Shader (`shaders/diamond_master.frag`)

```
diamond_master.frag  [GLSL 460 + flutter/runtime_effect]
  │
  ├── Uniforms (set by _configureShader each frame):
  │     uSize, uTime, uRefractionIndex, uSparkleIntensity,
  │     uFacetDepth, uBrightness, uContrast, uSaturation,
  │     uBlur, uLightPosition, uRotation, uScale, uUserImage
  │
  └── Per-pixel pipeline:
        1. Rotation + Scale     (rotate2D)
        2. Diamond facets       (3×3 Voronoi neighbor search)
        3. Refraction           (offset UV by facet normal × IOR)
        4. Image sample         (texture or 5-tap Gaussian blur)
        5. Colour grading       (brightness, contrast, saturation)
        6. Chromatic dispersion (separate R/B channel samples)
        7. Facet highlight      (Blinn-Phong, gold tint)
        8. Edge glow            (radial falloff × gold)
        9. Sparkle / light rays (cos-based rays × falloff)
       10. Time shimmer         (sin wave over elapsed seconds)
        → output: fragColor
```

---

## Layer 10 — Design Tokens (`lib/app_colors.dart`)

```
AppColors  [all static const Color]
  background    #0A0A0A   near-black canvas
  panel         #1A1A1A   side panels, cards
  panelBorder   #2A2A2A   dividers, borders
  gold          #D4AF37   ← brand colour used everywhere
  goldLight     #F4E4BC   soft gold highlight
  textPrimary   #FFFFFF   labels, titles
  textSecondary #888888   hints, captions
  uploadZone    #111111   upload target background
```

---

## Layer 11 — Tests (`test/widget_test.dart`)

```
5 test groups
  1. App launch smoke         — pumps StudioPage, finds "IconStudio" + "Export Icon"
  2. EditorState copyWith     — unit test: immutability guarantee
  3. Export button presence   — taps Export Icon button
  4. ShaderBuilder mounting   — mounts ShaderBuilder in widget tree
  5. SharedPreferences guard  — asserts main.dart contains zero SharedPreferences refs
```

---

## Layer 12 — CI Pipeline (`.github/workflows/ci.yml`)

```
Triggers: push / pull_request (all branches)

  my_first_job  → placeholder Hello World step
  analyze       → flutter analyze --fatal-infos
  test          → flutter test --coverage        [needs: analyze]
  build matrix  → [needs: test]
        ├── android  (ubuntu)  flutter build apk --debug
        ├── ios      (macos)   flutter build ios --debug --no-codesign
        └── web      (ubuntu)  flutter build web --release
```

---

## Layer 13 — Dependencies (`pubspec.yaml`)

```
Runtime
  flutter_shaders     ^0.1.2    GLSL shader runtime
  file_picker         ^6.1.1    image import + desktop save dialog
  path_provider       ^2.1.3    native file-system paths
  crypto              ^3.0.3    SHA-256 password hashing
  flutter_svg         ^2.0.10   SVG asset support
  firebase_core       ^2.32.0
  firebase_auth       ^4.20.0
  cloud_firestore     ^4.17.5
  firebase_storage    ^11.7.7
  shared_preferences  ^2.2.3    local editor state + auth state

Assets declared
  assets/icons/               bundled icon assets
  shaders/diamond_master.frag diamond refraction shader
```

---

## Complete Data-Flow Summary

```
User taps "Upload"
  → FilePicker → Uint8List bytes
  → editorState.copyWith(userImageBytes: bytes)
  → _setEditorState() → setState + EditorStorage.save()
  → PreviewCanvas rebuilds
  → ShaderBuilder feeds bytes into GLSL via AnimatedSampler
  → _configureShader() maps all EditorState fields → 15 GLSL uniforms
  → Ticker drives uTime → live sparkle + shimmer

User moves a slider
  → onChanged → _setEditorState(editorState.copyWith(field: value))
  → same rebuild path as above

User taps "Export"
  → RenderRepaintBoundary.toImage(pixelRatio: 3.0)
  → PNG bytes → saveExportedImage() → file saved / browser download

User opens Pack Editor
  → PacksScreen → PackEditorScreen → IconEditorSheet
  → StudioPage(embeddedMode: true)
  → onStateChanged stores state locally in IconEditorSheet
  → "Save" → FirebaseService.updateIcon()  or  addIconToPack()
```
