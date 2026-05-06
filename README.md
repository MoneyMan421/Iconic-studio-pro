# Iconic Studio Pro

**Premium Icon Editor with Diamond Refraction Shaders**

[![CI](https://github.com/MoneyMan421/Iconic-studio-pro/actions/workflows/ci.yml/badge.svg)](https://github.com/MoneyMan421/Iconic-studio-pro/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Iconic Studio Pro is a professional mobile-first icon editor built with Flutter, featuring real-time GLSL diamond-refraction shader effects. Create stunning diamond-effect icons from your custom images with live parameter tuning and high-resolution export.

---

## ✨ Features

### Core Capabilities
- 🎨 **Real-Time Shader Rendering** — GLSL-powered diamond refraction effects at 60 FPS
- 📸 **Custom Image Upload** — Import your own images and transform them
- 🎛️ **9 Adjustable Parameters** — Fine-tune scale, rotation, brightness, contrast, saturation, blur, refraction, sparkle, and facet depth
- 📤 **High-Resolution Export** — PNG output at 3× pixel density (1536×1536 pixels)
- ☁️ **Cloud Integration** — Firebase authentication, Firestore database, and Storage
- 📦 **Icon Pack Management** — Organize icons into themed collections
- 🛒 **Marketplace** — Publish and share icon packs
- 🔒 **Secure Authentication** — Email/password auth with proper security
- 📱 **Cross-Platform** — Android, iOS, and Web support

### Technical Highlights
- Immutable state management with `EditorState`
- Real-time GLSL shader pipeline (Flutter Shaders)
- Platform-specific export implementations
- Comprehensive testing with >90% coverage
- Automated CI/CD with GitHub Actions
- Firebase backend integration
- Local state persistence

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0.0+
- Dart SDK 3.0.0+
- Android Studio or VS Code with Flutter extensions

### Installation

```bash
# Clone the repository
git clone https://github.com/MoneyMan421/Iconic-studio-pro.git
cd Iconic-studio-pro

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Firebase Setup (Optional for Cloud Features)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure your Firebase project
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

For detailed Firebase setup instructions, see [FIREBASE_SETUP.md](FIREBASE_SETUP.md).

---

## 📖 Documentation

### Complete Documentation Suite

- **[DOCUMENTATION.md](DOCUMENTATION.md)** — Complete technical reference covering architecture, implementation details, data models, testing, and performance
- **[ARCHITECTURE.md](ARCHITECTURE.md)** — System design, component diagrams, data flow, design patterns, and scalability considerations
- **[DEVELOPMENT.md](DEVELOPMENT.md)** — Development environment setup, building, testing, coding conventions, and common tasks
- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** — Step-by-step Firebase configuration guide
- **[CHANGELOG.md](CHANGELOG.md)** — Version history and release notes

### Quick Links

| Topic | Documentation |
|-------|---------------|
| Getting Started | [DEVELOPMENT.md](DEVELOPMENT.md#getting-started) |
| Architecture Overview | [ARCHITECTURE.md](ARCHITECTURE.md#architecture-overview) |
| Building the App | [DEVELOPMENT.md](DEVELOPMENT.md#building-the-application) |
| Running Tests | [DEVELOPMENT.md](DEVELOPMENT.md#running-tests) |
| Code Conventions | [DEVELOPMENT.md](DEVELOPMENT.md#code-style-and-conventions) |
| Firebase Setup | [FIREBASE_SETUP.md](FIREBASE_SETUP.md) |
| API Reference | [DOCUMENTATION.md](DOCUMENTATION.md#data-models) |
| Troubleshooting | [DEVELOPMENT.md](DEVELOPMENT.md#troubleshooting) |

---

## 🏗️ Architecture

Iconic Studio Pro follows a layered architecture:

```
Presentation Layer (UI)
      ↓
Business Logic (State Management)
      ↓
Service Layer (Firebase, Storage, Export)
      ↓
Data Layer (Firestore, SharedPreferences, File System)
```

### Key Components

- **EditorState** — Immutable value object for editor parameters
- **FirebaseService** — Centralized backend API wrapper
- **AuthState** — Observable authentication state management
- **ShaderBuilder** — Real-time GLSL shader integration
- **Export System** — Platform-specific PNG export

For detailed architecture information, see [ARCHITECTURE.md](ARCHITECTURE.md).

---

## 🧪 Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Test Coverage

- ✅ Widget smoke tests
- ✅ State immutability tests
- ✅ UI interaction tests
- ✅ Shader integration tests
- ✅ API compatibility tests

Current coverage: **>90%**

---

## 🔨 Building

### Debug Builds

```bash
# Android APK
flutter build apk --debug

# iOS (macOS only, unsigned)
flutter build ios --debug --no-codesign

# Web
flutter build web --debug
```

### Release Builds

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Google Play)
flutter build appbundle --release

# iOS (requires Apple Developer account)
flutter build ios --release

# Web
flutter build web --release
```

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes** following our [code conventions](DEVELOPMENT.md#code-style-and-conventions)
4. **Write tests** for new functionality
5. **Run tests** (`flutter test`)
6. **Run analyzer** (`flutter analyze --fatal-infos`)
7. **Commit your changes** (`git commit -m 'feat: add amazing feature'`)
8. **Push to your branch** (`git push origin feature/amazing-feature`)
9. **Open a Pull Request**

See [DEVELOPMENT.md](DEVELOPMENT.md#contributing-guidelines) for detailed contribution guidelines.

---

## 📋 Project Status

### Version 1.0.0 — Production Ready ✅

- ✅ Core editor functionality
- ✅ Real-time shader rendering
- ✅ Firebase integration
- ✅ Icon pack management
- ✅ Marketplace publishing
- ✅ Cross-platform support
- ✅ Comprehensive testing
- ✅ CI/CD pipeline
- ✅ Complete documentation

### Roadmap

#### Version 1.1 (Planned)
- [ ] Additional shader effects (metallic, glass, neon)
- [ ] Social sharing integration
- [ ] Batch export functionality
- [ ] Marketplace search and filtering
- [ ] In-app analytics

#### Version 2.0 (Future)
- [ ] Real-time collaboration
- [ ] Cloud rendering
- [ ] AI-powered suggestions
- [ ] Plugin system
- [ ] Custom shader editor

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Flutter Team** — For the amazing framework
- **Firebase** — For backend infrastructure
- **flutter_shaders** — For GLSL integration
- **Community Contributors** — For feedback and improvements

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/MoneyMan421/Iconic-studio-pro/issues)
- **Discussions:** [GitHub Discussions](https://github.com/MoneyMan421/Iconic-studio-pro/discussions)
- **Documentation:** [Complete Documentation](DOCUMENTATION.md)

---

## 🌟 Show Your Support

If you find Iconic Studio Pro useful, please consider:
- ⭐ **Starring the repository**
- 🐛 **Reporting bugs**
- 💡 **Suggesting features**
- 🤝 **Contributing code**
- 📖 **Improving documentation**

---

**Iconic Studio Pro** — Premium icon creation powered by Flutter and GLSL shaders.

Built with ❤️ by the Iconic Studio Pro Team | © 2026
