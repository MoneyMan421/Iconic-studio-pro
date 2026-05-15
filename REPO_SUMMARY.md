# Iconic Studio Pro — Repository Summary Report

**Generated:** 2026-05-15  
**Package:** `iconic_studio_pro` · Flutter (Dart ≥ 3.0, Flutter stable channel)  
**Version:** 1.0.0+1  
**Platforms:** Android · iOS · Web

---

## What This App Is

**Iconic Studio Pro** is a premium, mobile-first icon editor built with Flutter.
Its signature feature is a real-time GLSL diamond-refraction shader rendered via
`flutter_shaders`. Users upload a custom image, wrap it in a live diamond effect,
tune a full set of visual parameters, and export the result as a high-resolution PNG.

A creator-marketplace layer is scaffolded (icon packs, Firestore, Storage) but is
not yet wired into the main navigation flow.

---

## Source File Map

| File | Purpose |
|---|---|
| `lib/main.dart` | App entry point, all core editor UI and logic |
| `lib/auth_screen.dart` | Local (SharedPreferences-backed) auth state, sign-up/sign-in/sign-out screens |
| `lib/editor_storage.dart` | Persists editor slider values and import counter across restarts |
| `lib/export_helper.dart` | Conditional export — routes to `export_io.dart` or `export_web.dart` |
| `lib/export_io.dart` | Native file-save via `path_provider` |
| `lib/export_web.dart` | Web download via `dart:html` anchor trigger |
| `lib/app_colors.dart` | Central `AppColors` constants (background, panel, gold, etc.) |
| `lib/firebase_service.dart` | Firebase auth, Firestore (packs/icons), Storage helpers — scaffolded |
| `lib/firebase_options.dart` | **Placeholder** FlutterFire config — must be replaced before Firebase goes live |
| `lib/packs_screen.dart` | Icon-pack list UI (Firestore-backed grid) |
| `lib/pack_editor_screen.dart` | Per-pack icon editor with embedded `StudioPage` |
| `shaders/diamond_master.frag` | GLSL fragment shader: Voronoi facets, refraction, dispersion, sparkle, shimmer |
| `assets/icons/` | Bundled icon assets |
| `test/widget_test.dart` | Widget smoke tests + EditorState unit tests |
| `.github/workflows/ci.yml` | CI: analyze → test → build (Android, iOS, Web) |
| `FIREBASE_SETUP.md` | Step-by-step guide for FlutterFire configuration |
| `deliverables/` | Internal planning documents (not shipped) |

---

## Core Editor Features

| Feature | Detail |
|---|---|
| Image import | `file_picker` with 2-import free tier; paywall after limit |
| Live GLSL preview | Diamond facets via Voronoi hash; animated light, sparkle, shimmer |
| Controls | Scale, Rotation, Brightness, Contrast, Saturation, Blur, Refraction Index, Sparkle Intensity, Facet Depth |
| Export | 3× pixel-ratio PNG via `RepaintBoundary.toImage` |
| Persistent state | All slider values + import counter saved in `SharedPreferences` via `EditorStorage` |
| Embedded mode | `StudioPage(embeddedMode: true)` skips storage and fires `onStateChanged` callback |
| Responsive layout | Side-panel desktop ≥600 px; stacked mobile < 600 px |

---

## Authentication

The current auth system is **local-only** — no remote back-end required:

- `AuthState` (ChangeNotifier) stores login state in `SharedPreferences`.
- Passwords are hashed with SHA-256 via the `crypto` package.
- `AuthGate` wraps the app root and shows `AuthScreen` until the user is logged in.
- A separate Firebase auth path exists in `firebase_service.dart` but is **not
  currently wired** into the main app flow.

---

## Firebase / Marketplace Layer (Scaffolded)

The following Firebase-backed features are **implemented but not yet integrated**
into the primary app navigation:

- `FirebaseService`: email auth, user profile (Firestore), pack CRUD, icon CRUD,
  Storage upload, import counter sync, marketplace publish/download.
- `PacksScreen`: grid of user-owned icon packs (Firestore stream).
- `PackEditorScreen`: per-pack icon management with embedded editor sheet.
- Firestore and Storage security rules documented in `FIREBASE_SETUP.md`.
- **Critical:** `lib/firebase_options.dart` still holds placeholder values and must
  be replaced with real keys from `flutterfire configure`.

---

## CI / Testing Status

| Check | Status |
|---|---|
| `flutter analyze --fatal-infos` | ❌ Currently failing on `main` |
| `flutter test` | ⏭ Skipped (blocked by analyze failure) |
| Android / iOS / Web builds | ⏭ Skipped (blocked by analyze failure) |

### Active Analyzer Failures (as of last CI run on `main`)

1. `lib/export_web.dart:2` — `dart:html` is deprecated; should use `package:web` + `dart:js_interop`
2. `lib/export_web.dart:12` — local variable `anchor` is unused
3. `lib/main.dart:10` — unused import `flutter_svg`
4. `lib/pack_editor_screen.dart:415` — unused field `_previewKey`
5. `lib/pack_editor_screen.dart:470` — `_packs` is private to `FirebaseService`; must use public API
6. `lib/pack_editor_screen.dart:536-538` — `embeddedMode`, `initialState`, `onStateChanged` named params not recognized (API mismatch)
7. `test/widget_test.dart:78` — `AppColors` not imported; const expression compile error

---

## Key Conventions

- **Colors** — use `AppColors` constants; never write raw `Color(0x…)` literals in widget code.
- **Color API** — use `color.withValues(alpha: x)`, not the deprecated `color.withOpacity(x)`.
- **EditorState** — immutable value object; always update via `.copyWith(…)`.
- **No SharedPreferences in `main.dart`** — persistence lives exclusively in `editor_storage.dart` and `auth_screen.dart`; a test enforces this.
- **Tests** — pump `MaterialApp(home: StudioPage())` directly; do **not** pump `IconStudioPro` (that exercises `AuthGate` and breaks studio assertions).

---

## Dependencies

| Package | Use |
|---|---|
| `flutter_shaders ^0.1.2` | GLSL shader rendering |
| `file_picker ^6.1.1` | Image import |
| `path_provider ^2.1.3` | Native file-save path |
| `crypto ^3.0.3` | Password hashing |
| `flutter_svg ^2.0.10` | SVG rendering (currently imported but unused in `main.dart`) |
| `firebase_core ^2.32.0` | Firebase initialization |
| `firebase_auth ^4.20.0` | Firebase email auth |
| `cloud_firestore ^4.17.5` | Pack and icon documents |
| `firebase_storage ^11.7.7` | Icon image uploads |
| `shared_preferences ^2.2.3` | Local editor state and auth persistence |

---

## Expansion Opportunities

| Priority | Area | What to Build |
|---|---|---|
| 🔴 Now | CI stabilization | Fix the 7 active analyzer errors so tests and builds can run |
| 🔴 Now | Firebase setup | Run `flutterfire configure`; wire `Firebase.initializeApp` at app startup |
| 🟠 Next | Auth unification | Decide local vs Firebase auth; remove the unused path |
| 🟠 Next | Navigation | Connect `PacksScreen` into the main app flow (tab bar or drawer) |
| 🟡 Soon | Real paywall | Replace the placeholder "coming soon" snackbar with RevenueCat/in-app purchase |
| 🟡 Soon | Editor polish | Undo/redo, presets, multiple export sizes/formats, onboarding tour |
| 🟢 Later | Marketplace | Public pack discovery, ratings, thumbnails, creator profiles |
| 🟢 Later | More shaders | Additional visual effects beyond diamond refraction |
| 🟢 Later | Web showcase | Landing page for the app |

---

*This report was auto-generated from a full source and CI review.*
