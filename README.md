# Iconic Studio Pro

Premium icon editor with animated diamond-refraction shaders, built with Flutter.

---

## Features

| Area | What's implemented |
|---|---|
| **Diamond shader** | Full GLSL fragment shader — faceted normals via noise gradient, Snell-style refraction offset, chromatic dispersion, Blinn-Phong specular, animated Voronoi-edge sparkles, Gaussian blur |
| **Transform** | Scale (0–100 %) and rotation (−180°–180°) applied to the preview canvas |
| **Adjustments** | Brightness, contrast, saturation, and per-pixel blur |
| **Diamond physics** | Refraction index, sparkle intensity, facet depth |
| **Import** | PNG / JPG via system file picker; file-size validation (≤ 5 MB) |
| **Export** | Captures the live shader canvas via `RepaintBoundary` → `toImage` and saves a 3× PNG to the Downloads/Documents folder |
| **Persistence** | All slider values and pro status are saved via `shared_preferences` and restored on next launch |
| **Paywall** | Free tier: 2 imports. "Upgrade Now" persists the pro flag so subsequent imports are unlimited |
| **Error handling** | All async I/O (file pick, export, prefs) wrapped in try/catch with SnackBar feedback |

---

## Getting started

```bash
flutter pub get
flutter run
```

Tested with a recent Flutter stable release. Flutter 3.0 is not supported — this project uses newer `Color` APIs such as `Color.withValues(...)` and `Color.toARGB32()`.

---

## Project structure

```
lib/
  main.dart          # Single-file app: state, pages, widgets
shaders/
  diamond_master.frag  # GLSL 460 fragment shader
assets/
  icons/
    app_icon.svg     # App icon placeholder
test/
  widget_test.dart   # Unit + widget smoke tests
.github/
  workflows/
    flutter.yml      # CI: analyse + test
```

---

## Running tests

```bash
flutter test
```

---

## Roadmap

- [ ] Real in-app purchase backend (RevenueCat / Stripe)
- [ ] Cloud sync of projects
- [ ] SVG import (render to raster before passing to shader)
- [ ] Export size picker (512 px, 1024 px, 2048 px)
- [ ] Preset shader styles (sapphire, emerald, ruby)
