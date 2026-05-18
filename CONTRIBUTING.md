# Contributing to Iconic Studio Pro

Thank you for your interest in contributing! This document outlines the process for
proposing changes, the coding conventions we follow, and the quality gates every
change must pass before it can be merged.

---

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [How to Contribute](#how-to-contribute)
4. [Development Workflow](#development-workflow)
5. [Coding Conventions](#coding-conventions)
6. [Testing Requirements](#testing-requirements)
7. [Commit Message Format](#commit-message-format)
8. [Pull Request Checklist](#pull-request-checklist)

---

## Code of Conduct

By participating in this project you agree to behave professionally and
respectfully toward all contributors. Harassment, discrimination, and personal
attacks are not tolerated.

---

## Getting Started

### Prerequisites

| Tool | Minimum Version |
|------|----------------|
| Flutter SDK | 3.0.0 |
| Dart SDK | 3.0.0 |
| Android Studio / VS Code | Latest stable |

### First-time Setup

```bash
# Clone the repository
git clone https://github.com/MoneyMan421/Iconic-studio-pro.git
cd Iconic-studio-pro

# Install dependencies
flutter pub get

# Verify environment
flutter doctor

# Run all tests (must pass before any PR)
flutter test

# Run the analyzer (CI treats infos as errors)
flutter analyze --fatal-infos
```

---

## How to Contribute

### Bug Reports

Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md). Include:
- Steps to reproduce
- Expected vs. actual behaviour
- Device/OS/Flutter version
- Relevant log output or screenshots

### Feature Requests

Use the [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md). Include:
- The user problem you are solving
- Your proposed solution
- Any alternatives considered

### Code Contributions

1. **Find or create an issue** describing what you plan to build.
2. **Fork the repository** and create a feature branch off `main`:
   ```bash
   git checkout -b feat/my-feature-name
   ```
3. **Write code** following the conventions below.
4. **Write tests** — every new feature or bug fix must include tests.
5. **Open a pull request** using the [PR template](.github/pull_request_template.md).

---

## Development Workflow

```
main (protected)
  └── feat/<description>   feature branches
  └── fix/<description>    bug fix branches
  └── chore/<description>  maintenance branches
  └── docs/<description>   documentation-only changes
```

- Keep branches short-lived (merge within 1–2 sprints).
- Rebase or merge `main` into your branch before opening a PR to avoid conflicts.
- Squash fixup commits before requesting review.

---

## Coding Conventions

### Dart / Flutter

- **Colors** — always use `AppColors` constants; never raw `Color(0x…)` literals in
  widget code.
- **Deprecated Color API** — use `color.withValues(alpha: x)`, not
  `color.withOpacity(x)`.
- **EditorState** — immutable value object; always update via `.copyWith(…)`.
- **SharedPreferences in main.dart** — prohibited. All persistence must go through
  `EditorStorage` or `AuthState`.
- **Imports** — no circular imports between `main.dart` and screen files.
- **Public APIs** — document every public class and method with a `///` doc comment.

### File Organisation

```
lib/
  main.dart              — editor entry point + EditorState + StudioPage
  auth_screen.dart       — AuthState + auth UI
  firebase_service.dart  — Firebase API wrapper (static methods only)
  pack_editor_screen.dart — pack / icon editor UI
  packs_screen.dart      — pack list UI
  editor_storage.dart    — SharedPreferences persistence helper
  export_helper.dart     — conditional export re-export
  export_io.dart         — native file export
  export_web.dart        — browser download export
  app_colors.dart        — AppColors constants
```

### GLSL (shaders/)

- Use `#version 460 core` and the `flutter/runtime_effect.glsl` include.
- Name uniforms with the `u` prefix (`uTime`, `uBrightness`, …).
- Uniform order in the `.frag` file **must** match the `setFloat` call order in
  `_configureShader`.

---

## Testing Requirements

| Requirement | Threshold |
|-------------|-----------|
| All existing tests must pass | 100 % |
| New features must include tests | Required |
| `flutter analyze --fatal-infos` must pass | Required |

Run the full suite locally before pushing:

```bash
flutter test --coverage
flutter analyze --fatal-infos
```

Tests live in `test/widget_test.dart`. Follow the existing pattern:
- Group related tests with `group(...)`.
- Set up mock `SharedPreferences` values with `SharedPreferences.setMockInitialValues`.
- Pump `MaterialApp(home: const StudioPage())` — **not** `IconStudioPro` — to bypass
  `AuthGate` in widget tests.

---

## Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

| Type | When to use |
|------|------------|
| `feat` | New user-visible feature |
| `fix` | Bug fix |
| `chore` | Maintenance, dependency updates |
| `docs` | Documentation only |
| `test` | Adding or updating tests |
| `refactor` | Code change without behaviour change |
| `perf` | Performance improvement |
| `ci` | CI/CD pipeline changes |

Examples:
```
feat(editor): add Reset to Defaults button
fix(paywall): remove false Cloud sync advertising
test(auth): add sign-up and logout unit tests
ci: remove placeholder my_first_job step
```

---

## Pull Request Checklist

Before requesting review, confirm every item below:

- [ ] `flutter test` passes locally
- [ ] `flutter analyze --fatal-infos` passes locally
- [ ] New code follows coding conventions (AppColors, withValues, no SharedPreferences in main.dart)
- [ ] New features include tests
- [ ] No circular imports introduced
- [ ] `CHANGELOG.md` updated under `[Unreleased]`
- [ ] PR title follows Conventional Commits format
- [ ] PR description filled in using the template

---

Thank you for helping make Iconic Studio Pro better! 🎉
