# Iconic Studio Pro — Development Guide

**Version:** 1.0.0  
**Last Updated:** May 2026

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Development Environment Setup](#development-environment-setup)
3. [Building the Application](#building-the-application)
4. [Running Tests](#running-tests)
5. [Code Style and Conventions](#code-style-and-conventions)
6. [Development Workflow](#development-workflow)
7. [Debugging](#debugging)
8. [Common Development Tasks](#common-development-tasks)
9. [Contributing Guidelines](#contributing-guidelines)
10. [Troubleshooting](#troubleshooting)

---

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0.0 or higher)
- **Dart SDK** (3.0.0 or higher)
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** for version control
- **Firebase CLI** (optional, for Firebase configuration)

### Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/MoneyMan421/Iconic-studio-pro.git
cd Iconic-studio-pro

# 2. Install dependencies
flutter pub get

# 3. Verify setup
flutter doctor

# 4. Run the app
flutter run
```

---

## Development Environment Setup

### 1. Flutter Installation

#### macOS
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

#### Windows
```powershell
# Download Flutter SDK from flutter.dev
# Extract to C:\src\flutter
# Add to PATH: C:\src\flutter\bin

# Verify installation
flutter doctor
```

#### Linux
```bash
# Download Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.x.x-stable.tar.xz
tar xf flutter_linux_3.x.x-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

### 2. IDE Setup

#### VS Code (Recommended)

**Install Extensions:**
```
- Flutter (Dart Code)
- Dart
- Flutter Widget Snippets
- GitLens
- Error Lens
```

**VS Code Settings (`.vscode/settings.json`):**
```json
{
  "dart.lineLength": 80,
  "editor.formatOnSave": true,
  "dart.debugExternalPackageLibraries": false,
  "dart.debugSdkLibraries": false,
  "[dart]": {
    "editor.rulers": [80],
    "editor.selectionHighlight": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": false
  }
}
```

#### Android Studio

**Install Plugins:**
- Flutter plugin
- Dart plugin

**Configure:**
1. File → Settings → Languages & Frameworks → Flutter
2. Set Flutter SDK path
3. Enable Dart support

### 3. Device Setup

#### Android Emulator
```bash
# Create Android Virtual Device
flutter emulators --create --name test_emulator

# Launch emulator
flutter emulators --launch test_emulator

# Or use Android Studio AVD Manager
```

#### iOS Simulator (macOS only)
```bash
# List available simulators
xcrun simctl list

# Open simulator
open -a Simulator

# Or via Flutter
flutter run
```

#### Physical Device
```bash
# Android
adb devices

# iOS (requires Xcode)
ios-deploy --detect
```

### 4. Firebase Setup

See `FIREBASE_SETUP.md` for complete Firebase configuration instructions.

**Quick Firebase Setup:**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase project
flutterfire configure --project=YOUR_PROJECT_ID

# This generates lib/firebase_options.dart
```

---

## Building the Application

### Debug Builds

#### Android (APK)
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

#### iOS (Unsigned)
```bash
flutter build ios --debug --no-codesign
# Output: build/ios/iphoneos/Runner.app
```

#### Web
```bash
flutter build web --debug
# Output: build/web/
```

### Release Builds

#### Android (APK)
```bash
# Build release APK
flutter build apk --release

# Build App Bundle (for Google Play)
flutter build appbundle --release
```

#### iOS (Requires Apple Developer Account)
```bash
# Build release IPA
flutter build ios --release

# Archive in Xcode for App Store submission
open ios/Runner.xcworkspace
```

#### Web
```bash
flutter build web --release
# Output: build/web/
```

### Build Optimization

#### Reduce Build Size
```bash
# Split APKs by architecture
flutter build apk --split-per-abi

# This creates:
# - app-armeabi-v7a-release.apk
# - app-arm64-v8a-release.apk
# - app-x86_64-release.apk
```

#### Tree Shaking
```dart
// Enabled by default in release mode
// Removes unused code automatically
```

---

## Running Tests

### Unit Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Widget Tests
```bash
# Widget tests are in test/widget_test.dart
flutter test test/widget_test.dart

# Run specific test by name
flutter test --name "renders key studio UI"
```

### Integration Tests
```bash
# (Not currently implemented)
# Would be in integration_test/ directory
flutter test integration_test
```

### Test Conventions

**Setup SharedPreferences Mock:**
```dart
setUp(() {
  SharedPreferences.setMockInitialValues({});
});
```

**Test StudioPage Directly:**
```dart
testWidgets('test name', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: StudioPage()),
  );
  // Test assertions...
});
```

**Do NOT test IconStudioPro root** (includes AuthGate which requires auth setup).

---

## Code Style and Conventions

### Dart Style Guide

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).

**Key Rules:**
- Line length: 80 characters
- Indentation: 2 spaces
- Use `const` constructors wherever possible
- Prefer `final` over `var` when value doesn't change
- Use trailing commas for better formatting

### Naming Conventions

```dart
// Classes: UpperCamelCase
class EditorState { }
class FirebaseService { }

// Variables/Functions: lowerCamelCase
final editorState = EditorState();
void updateState() { }

// Constants: lowerCamelCase
const double defaultScale = 50.0;

// Private: prefix with underscore
int _privateField = 0;
void _privateMethod() { }

// Files: snake_case
// editor_state.dart
// firebase_service.dart
```

### Color Usage

**Always use AppColors constants:**
```dart
// ✅ CORRECT
Container(color: AppColors.background)

// ❌ WRONG
Container(color: Color(0xFF0A0E27))
```

**Available Colors:**
- `AppColors.background` - Main background
- `AppColors.panel` - Panel/card background
- `AppColors.panelBorder` - Border color
- `AppColors.gold` - Accent/primary color
- `AppColors.textPrimary` - Main text
- `AppColors.textSecondary` - Secondary text

### Deprecated API Handling

**Color Opacity:**
```dart
// ✅ CORRECT (New API)
color.withValues(alpha: 0.5)

// ❌ WRONG (Deprecated)
color.withOpacity(0.5)
```

### State Management Pattern

**EditorState is Immutable:**
```dart
// ✅ CORRECT
final newState = editorState.copyWith(scale: 75);
setState(() {
  editorState = newState;
});

// ❌ WRONG
editorState.scale = 75;  // Won't compile (final fields)
```

### File Organization

```dart
// 1. Imports (grouped and sorted)
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import 'app_colors.dart';
import 'firebase_service.dart';

// 2. Constants
const double kDefaultScale = 50.0;

// 3. Classes
class MyWidget extends StatelessWidget {
  // Constructor
  const MyWidget({super.key});
  
  // Public methods
  @override
  Widget build(BuildContext context) { }
  
  // Private methods
  void _helperMethod() { }
}
```

---

## Development Workflow

### Branch Strategy

```bash
# Main branch (production)
main

# Feature branches
feature/add-new-shader
feature/marketplace-search

# Bug fix branches
fix/export-crash-android
fix/auth-validation

# Release branches
release/v1.1.0
```

### Commit Message Format

```
type(scope): brief description

Detailed explanation if needed.

Fixes #123
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Code style (formatting, etc.)
- `refactor` - Code refactoring
- `test` - Adding tests
- `chore` - Maintenance tasks

**Examples:**
```bash
git commit -m "feat(shader): add metallic shader effect"
git commit -m "fix(export): prevent crash on Android 13"
git commit -m "docs(readme): update setup instructions"
```

### Pull Request Process

1. **Create Feature Branch**
```bash
git checkout -b feature/my-feature
```

2. **Make Changes**
```bash
# Edit files
git add .
git commit -m "feat(scope): description"
```

3. **Run Tests Locally**
```bash
flutter analyze --fatal-infos
flutter test
flutter build apk --debug
```

4. **Push and Create PR**
```bash
git push origin feature/my-feature
# Create PR on GitHub
```

5. **CI Checks**
- Analyze job must pass
- Test job must pass
- Build jobs must pass

6. **Code Review**
- Address reviewer feedback
- Update PR as needed

7. **Merge**
- Squash and merge (preferred)
- Delete feature branch

---

## Debugging

### Flutter DevTools

```bash
# Start app in debug mode
flutter run

# Open DevTools
# Press 'w' in terminal or visit URL shown
```

**DevTools Features:**
- Widget Inspector
- Performance overlay
- Memory profiler
- Network monitor

### VS Code Debugging

**Launch Configuration (`.vscode/launch.json`):**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter",
      "request": "launch",
      "type": "dart",
      "flutterMode": "debug"
    },
    {
      "name": "Flutter (Profile)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "profile"
    }
  ]
}
```

**Set Breakpoints:**
- Click left margin in editor
- Code execution pauses at breakpoint
- Inspect variables, step through code

### Logging

```dart
// Debug logging
debugPrint('Editor state updated: $editorState');

// Conditional logging
if (kDebugMode) {
  print('Debug info: $_internalState');
}

// Firebase logging
FirebaseCrashlytics.instance.log('User exported icon');
```

### Common Debug Scenarios

#### Shader Not Rendering
```bash
# Check shader compilation errors
flutter run --verbose

# Look for GLSL compile errors in output
```

#### Export Failing
```dart
// Add try-catch for debugging
try {
  await exportIcon(boundary);
} catch (e, stackTrace) {
  debugPrint('Export error: $e');
  debugPrint('Stack trace: $stackTrace');
}
```

#### State Not Persisting
```dart
// Verify SharedPreferences writes
final prefs = await SharedPreferences.getInstance();
print('Saved state: ${prefs.getString("editorState")}');
```

---

## Common Development Tasks

### Adding a New Shader Parameter

**1. Update EditorState:**
```dart
class EditorState {
  final double myNewParam;
  
  EditorState({
    // ...
    this.myNewParam = 1.0,
  });
  
  EditorState copyWith({
    // ...
    double? myNewParam,
  }) => EditorState(
    // ...
    myNewParam: myNewParam ?? this.myNewParam,
  );
}
```

**2. Add Shader Uniform:**
```glsl
// shaders/diamond_master.frag
uniform float uMyNewParam;
```

**3. Pass Uniform from Dart:**
```dart
shader.setFloat(uniformIndex, editorState.myNewParam);
```

**4. Add UI Slider:**
```dart
_buildSlider(
  label: 'My New Param',
  value: editorState.myNewParam,
  min: 0,
  max: 10,
  onChanged: (v) => _updateState(
    editorState.copyWith(myNewParam: v)
  ),
)
```

**5. Update Tests:**
```dart
test('copyWith updates myNewParam', () {
  final state = EditorState();
  final updated = state.copyWith(myNewParam: 5.0);
  expect(updated.myNewParam, 5.0);
});
```

### Adding a New Screen

**1. Create Screen File:**
```dart
// lib/my_new_screen.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class MyNewScreen extends StatefulWidget {
  const MyNewScreen({super.key});
  
  @override
  State<MyNewScreen> createState() => _MyNewScreenState();
}

class _MyNewScreenState extends State<MyNewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Screen')),
      body: Center(child: Text('Content')),
    );
  }
}
```

**2. Add Navigation:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const MyNewScreen()),
);
```

### Updating Dependencies

```bash
# Check for updates
flutter pub outdated

# Update to latest compatible versions
flutter pub upgrade

# Update to latest (including breaking changes)
flutter pub upgrade --major-versions

# Update specific package
flutter pub upgrade package_name
```

### Adding Firebase Collection

**1. Define Data Model:**
```dart
class MyModel {
  final String id;
  final String name;
  
  MyModel({required this.id, required this.name});
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
  
  factory MyModel.fromJson(Map<String, dynamic> json) => MyModel(
    id: json['id'],
    name: json['name'],
  );
}
```

**2. Add Service Methods:**
```dart
// In firebase_service.dart
static Future<void> createMyModel(MyModel model) async {
  await _db.collection('myModels').doc(model.id).set(model.toJson());
}

static Stream<List<MyModel>> watchMyModels() {
  return _db.collection('myModels').snapshots().map(
    (snapshot) => snapshot.docs
      .map((doc) => MyModel.fromJson(doc.data()))
      .toList(),
  );
}
```

**3. Update Firestore Rules:**
```javascript
match /myModels/{modelId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null;
}
```

---

## Contributing Guidelines

### Before Contributing

1. **Check Existing Issues** - Search for related issues
2. **Discuss Major Changes** - Open an issue first for big features
3. **Follow Conventions** - Match existing code style
4. **Write Tests** - Cover new functionality
5. **Update Docs** - Document new features

### Contribution Checklist

- [ ] Code follows style guide
- [ ] No analyzer warnings (`flutter analyze --fatal-infos`)
- [ ] Tests pass (`flutter test`)
- [ ] Builds succeed on all platforms
- [ ] Documentation updated
- [ ] Commit messages follow format
- [ ] PR description explains changes

### Code Review Guidelines

**As Reviewer:**
- Be constructive and helpful
- Ask questions to understand intent
- Suggest alternatives when appropriate
- Approve when satisfied

**As Author:**
- Respond to all comments
- Make requested changes or explain why not
- Keep PR scope focused
- Update PR description as needed

---

## Troubleshooting

### Common Issues

#### "Shader failed to compile"
```bash
# Check GLSL syntax
flutter run --verbose

# Look for shader compilation errors
# Common issues: typos, wrong uniform types, syntax errors
```

**Solution:** Review shader code, check Flutter GLSL documentation

#### "Unable to load asset"
```yaml
# Ensure asset is listed in pubspec.yaml
flutter:
  assets:
    - assets/icons/
  shaders:
    - shaders/diamond_master.frag
```

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### "SharedPreferences not working"
```dart
// Initialize in tests
setUp(() {
  SharedPreferences.setMockInitialValues({});
});
```

#### "Firebase not configured"
```bash
# Run FlutterFire CLI
flutterfire configure --project=YOUR_PROJECT_ID

# Download google-services.json
# Place in android/app/
```

#### "Build failed: Android license not accepted"
```bash
flutter doctor --android-licenses
# Accept all licenses
```

#### "iOS build failed: Pod install error"
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter run
```

### Performance Issues

#### Slow Rendering
- Check shader complexity
- Reduce texture size
- Profile with DevTools
- Use `const` constructors

#### High Memory Usage
- Dispose controllers properly
- Compress images before loading
- Use `RepaintBoundary` strategically

#### Slow Build Times
```bash
# Clear build cache
flutter clean

# Use build caching
flutter run --build-cache

# Parallelize builds
flutter build apk --split-per-abi
```

---

## Additional Resources

### Documentation
- [Flutter Official Docs](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Firebase Flutter Docs](https://firebase.flutter.dev/)

### Community
- [Flutter Discord](https://discord.gg/flutter)
- [r/FlutterDev](https://reddit.com/r/FlutterDev)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

### Tools
- [Flutter DevTools](https://docs.flutter.dev/development/tools/devtools/overview)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli)
- [Very Good CLI](https://pub.dev/packages/very_good_cli)

---

**Document Version:** 1.0  
**Last Review Date:** May 6, 2026  
**Maintained By:** Development Team
