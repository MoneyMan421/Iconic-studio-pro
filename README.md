# Iconic Studio Pro

Premium mobile-first icon editor built with Flutter, featuring a real-time GLSL diamond-refraction shader.

## Features

- **Diamond shader** – live GLSL refraction effect powered by `flutter_shaders`
- **Full image controls** – scale, rotation, brightness, contrast, saturation, blur
- **Diamond physics** – tunable refraction index, sparkle intensity, and facet depth
- **Export** – save finished icons as PNG at 3× pixel density
- **Auth gate** – sign-up / sign-in / sign-out with local persistence via `SharedPreferences`
- **Paywall** – 2 free imports; Pro Monthly ($4.99/mo) or Pro Lifetime ($49.99) to unlock unlimited imports and extra shaders
- **Responsive layout** – dedicated mobile and desktop/tablet layouts

## Getting started

```bash
flutter pub get
flutter run
```

## Running tests

```bash
flutter test --coverage
```

## CI

GitHub Actions runs **analyze → test → build** on every push and pull request (Android + iOS).

## Project layout

| Path | Purpose |
|---|---|
| `lib/main.dart` | App entry point, editor UI and all core logic |
| `lib/auth_screen.dart` | Auth state, sign-up, sign-in, sign-out screens |
| `shaders/diamond_master.frag` | GLSL diamond-refraction fragment shader |
| `assets/icons/` | Bundled icon assets |
| `test/widget_test.dart` | Widget and unit tests |
| `.github/workflows/ci.yml` | CI pipeline |
