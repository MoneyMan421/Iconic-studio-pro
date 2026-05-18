# Changelog

All notable changes to Iconic Studio Pro will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Reset to Defaults button** — appears at the bottom of the editor control panel;
  resets all numeric parameters to factory values while preserving the loaded image.
- **CONTRIBUTING.md** — contributor guide covering setup, coding conventions, testing
  requirements, commit format, and PR checklist.
- **GitHub issue templates** — structured bug-report and feature-request forms
  (`.github/ISSUE_TEMPLATE/`).
- **GitHub PR template** — standardised pull-request checklist
  (`.github/pull_request_template.md`).
- **`EditorStorage` unit tests** — save/load round-trip, defaults, and overwrite
  scenarios.
- **`PaywallModal` widget tests** — tier rendering, callback wiring, copy
  accuracy, and false-advertising guard (`Cloud sync` must not appear).
- **Additional `AuthState` tests** — wrong password, unknown email, no-account,
  sign-up, and logout flows.

### Changed
- **PaywallModal Pro Monthly features** — replaced the inaccurate *Cloud sync*
  claim with *Early shader access* and *Priority support*.
- **Paywall "Upgrade Now" flow** — replaced the dead-end "coming soon" snackbar
  with a clear dialog explaining that in-app purchases are not yet available.
- **CI workflow** — removed the `my_first_job` placeholder step that referenced
  the non-existent `actions/hello_world@main` action, causing all CI runs to
  contain an error-level job.

### Fixed
- False advertising: `PaywallModal` no longer lists *Cloud sync* as a Pro
  feature when no sync functionality exists.
- Stale CI job: `my_first_job` referenced a non-existent GitHub Action and
  produced a mandatory-error job on every run.

### Added (Documentation)
- Comprehensive technical documentation (DOCUMENTATION.md)
- Architecture documentation (ARCHITECTURE.md)
- Development guide (DEVELOPMENT.md)
- This changelog file

## [1.0.0] - 2026-05-06

### Added
- Initial release of Iconic Studio Pro
- Diamond refraction shader effect with real-time rendering
- Custom image upload and manipulation
- 9 adjustable parameters (scale, rotation, brightness, contrast, saturation, blur, refraction, sparkle, facet depth)
- High-resolution PNG export (3× pixel density)
- Firebase authentication (email/password)
- Cloud Firestore database integration
- Firebase Storage for image hosting
- Icon pack management system
- Pack editor with add/edit/delete functionality
- Marketplace publishing capabilities
- Local state persistence via SharedPreferences
- Cross-platform support (Android, iOS, Web)
- Comprehensive test suite with widget and unit tests
- CI/CD pipeline with GitHub Actions
  - Automated code analysis
  - Automated testing with coverage
  - Multi-platform builds (Android, iOS, Web)

### Security
- Password hashing (SHA-256 for local auth)
- Firebase Auth integration with bcrypt
- Firestore security rules (user-scoped access)
- Storage security rules (owner-only writes)
- Input validation for email and parameters

### Technical
- Flutter 3.0.0+ support
- Dart 3.0.0+ support
- GLSL 460 core shader language
- Immutable state pattern (EditorState)
- Platform abstraction for export system
- Observer pattern for auth state management
- Service locator pattern for Firebase operations

## [0.9.0-beta] - 2026-04-15

### Added
- Beta release for testing
- Core editor functionality
- Basic shader rendering
- Firebase integration setup

### Changed
- Improved shader performance
- Enhanced UI responsiveness

### Fixed
- Export crashes on Android 13
- Shader compilation issues on older devices
- State persistence bugs

## [0.5.0-alpha] - 2026-03-01

### Added
- Alpha release
- Proof of concept shader editor
- Basic parameter controls
- Local file export

### Known Issues
- Performance issues on low-end devices
- Limited shader effects
- No cloud integration

---

## Release Types

- **Major (X.0.0)** - Breaking changes, major new features
- **Minor (1.X.0)** - New features, non-breaking changes
- **Patch (1.0.X)** - Bug fixes, minor improvements

## Upgrade Guide

### From 0.9.0-beta to 1.0.0
1. Update dependencies: `flutter pub upgrade`
2. Run Firebase configuration: `flutterfire configure`
3. Update Firestore and Storage security rules (see FIREBASE_SETUP.md)
4. Clear app data if upgrading from beta
5. Rebuild: `flutter clean && flutter pub get && flutter run`

---

## Categories

- **Added** - New features
- **Changed** - Changes to existing functionality
- **Deprecated** - Features that will be removed
- **Removed** - Removed features
- **Fixed** - Bug fixes
- **Security** - Security improvements
- **Technical** - Technical/infrastructure changes

---

**Changelog Version:** 1.0  
**Last Updated:** May 6, 2026
