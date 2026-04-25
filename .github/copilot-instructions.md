# GitHub Copilot Instructions

## Project overview

**Yes — Iconic Studio Pro is the only app in this repository.**

There is one Flutter application here: **Iconic Studio Pro** (`package:iconic_studio_pro`).
No other apps, micro-services, or sub-packages exist alongside it.

## What Iconic Studio Pro is

Iconic Studio Pro is a premium, mobile-first icon editor built with Flutter.
Its headline feature is a real-time GLSL diamond-refraction shader rendered via
`package:flutter_shaders`. Users can:

- Upload a custom image and wrap it in a diamond-effect icon.
- Tune scale, rotation, brightness, contrast, saturation, blur, refraction index,
  sparkle intensity, and facet depth with live preview.
- Export the finished icon as a PNG at 3× pixel density.
- Unlock unlimited imports and extra shaders via an in-app paywall (Pro Monthly /
  Pro Lifetime).

Authentication (sign-up / sign-in / sign-out) is handled by `lib/auth_screen.dart`
using `SharedPreferences` for local persistence — no remote back-end is involved.

## Repository layout

| Path | Purpose |
|---|---|
| `lib/main.dart` | App entry point, all core UI and editor logic |
| `lib/auth_screen.dart` | Auth state, sign-up, sign-in, sign-out screens |
| `shaders/diamond_master.frag` | GLSL diamond-refraction fragment shader |
| `assets/icons/` | Bundled icon assets (required by `pubspec.yaml`) |
| `test/widget_test.dart` | Widget and unit tests |
| `.github/workflows/ci.yml` | CI: analyze → test → build (Android + iOS) |
| `deliverables/` | Issue tracking documents (not shipped in the app) |

## Key conventions

- **Colors** — use the `AppColors` constants; never add raw `Color(0x…)` literals in
  widget code.
- **Deprecated Color API** — use `color.withValues(alpha: x)`, not `color.withOpacity(x)`.
- **EditorState** — immutable value object; always update via `.copyWith(…)`.
- **No SharedPreferences in `main.dart`** — persistence is handled exclusively inside
  `lib/auth_screen.dart`.
- **Dart analysis** — CI runs `flutter analyze --fatal-infos`; keep the analyzer clean.
- **Tests** — pump `MaterialApp(home: const StudioPage())` directly; do **not** pump
  `const IconStudioPro()` (that would exercise the auth gate and fail studio assertions).
