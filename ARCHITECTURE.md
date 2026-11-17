# Iconic Studio Pro — Architecture Documentation

**Version:** 1.0.0  
**Last Updated:** May 2026

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Design Principles](#design-principles)
3. [Layer Architecture](#layer-architecture)
4. [Component Diagram](#component-diagram)
5. [Data Flow](#data-flow)
6. [State Management](#state-management)
7. [Module Breakdown](#module-breakdown)
8. [Design Patterns](#design-patterns)
9. [Security Architecture](#security-architecture)
10. [Performance Architecture](#performance-architecture)

---

## Architecture Overview

Iconic Studio Pro follows a **layered architecture** with clear separation between presentation, business logic, and data layers. The application is built using Flutter's reactive framework with custom state management patterns optimized for real-time graphics rendering.

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  ┌────────────┐  ┌────────────┐  ┌────────────────────────┐ │
│  │   Auth UI  │  │ Editor UI  │  │  Pack Management UI   │ │
│  └────────────┘  └────────────┘  └────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                      Business Logic                          │
│  ┌────────────┐  ┌────────────┐  ┌────────────────────────┐ │
│  │ Auth State │  │   Editor   │  │    Pack Editor        │ │
│  │ Management │  │   State    │  │    Logic              │ │
│  └────────────┘  └────────────┘  └────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                       Service Layer                          │
│  ┌────────────┐  ┌────────────┐  ┌────────────────────────┐ │
│  │  Firebase  │  │  Storage   │  │    Export Service     │ │
│  │  Service   │  │  Service   │  │                       │ │
│  └────────────┘  └────────────┘  └────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│  ┌────────────┐  ┌────────────┐  ┌────────────────────────┐ │
│  │  Firebase  │  │   Local    │  │    File System        │ │
│  │  Firestore │  │ SharedPrefs│  │                       │ │
│  └────────────┘  └────────────┘  └────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## Design Principles

### 1. Separation of Concerns
Each module has a single, well-defined responsibility:
- **UI Layer:** Only rendering and user interactions
- **Business Logic:** State transformations and validation
- **Service Layer:** Backend communication and platform APIs
- **Data Layer:** Persistence and retrieval

### 2. Immutability
Core state objects (EditorState) are immutable value objects:
```dart
class EditorState {
  final double scale;
  final double rotation;
  // ... all fields are final
  
  EditorState copyWith({...}) => EditorState(...);
}
```

Benefits:
- Predictable state changes
- Easy debugging and time-travel
- Thread-safe operations
- Efficient change detection

### 3. Single Source of Truth
- Editor state lives in `_StudioPageState`
- Auth state managed by `AuthState` (ChangeNotifier)
- Firebase data synchronized from server

### 4. Platform Abstraction
Platform-specific code is isolated using conditional imports:
```dart
export 'export_io.dart' if (dart.library.html) 'export_web.dart';
```

### 5. Fail-Safe Defaults
All parameters have sensible default values:
```dart
EditorState({
  this.scale = 50,
  this.rotation = 0,
  this.brightness = 100,
  // ...
});
```

---

## Layer Architecture

### Presentation Layer

#### Responsibilities
- Render UI components
- Handle user input
- Display loading states
- Show error messages

#### Key Components
```dart
// Main app wrapper
class IconStudioPro extends StatelessWidget
  ├─ MaterialApp configuration
  ├─ Theme setup
  └─ AuthGate routing

// Authentication UI
class AuthGate extends StatelessWidget
  ├─ Check auth state
  ├─ Route to login or editor
  └─ Handle auth callbacks

// Editor interface
class StudioPage extends StatefulWidget
  ├─ Parameter sliders
  ├─ Shader preview
  ├─ Image picker
  └─ Export button

// Pack management
class PackEditorScreen extends StatefulWidget
  ├─ Icon grid
  ├─ Add/edit/delete icons
  └─ Publish controls
```

#### UI Patterns
- **Declarative UI:** All UI derived from state
- **Builder pattern:** ShaderBuilder for graphics
- **Composition:** Small, reusable widgets
- **Responsive:** Adapts to screen size

### Business Logic Layer

#### EditorState Management
```dart
class _StudioPageState extends State<StudioPage> {
  EditorState editorState = EditorState();  // Current state
  
  void _updateState(EditorState newState) {
    setState(() {
      editorState = newState;  // Triggers rebuild
    });
    _saveState(newState);  // Persist to storage
  }
}
```

#### State Transitions
```
User Input → Validation → State Update → Persistence → UI Rebuild
```

#### Validation Rules
- Scale: 0-100
- Rotation: 0-360 (wraps)
- Brightness/Contrast/Saturation: 0-200
- Blur: 0-10
- Refraction: 1.0-3.0
- Sparkle/Facet: 0-1.0

### Service Layer

#### FirebaseService Architecture
```dart
class FirebaseService {
  // Singleton instances
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;
  
  // Public API - Authentication
  static Future<UserCredential> signUp(...)
  static Future<UserCredential> signIn(...)
  static Future<void> signOut()
  
  // Public API - Firestore
  static Future<void> createPack(...)
  static Future<void> updatePack(...)
  static Future<void> deletePack(...)
  static Stream<QuerySnapshot> watchPacks(...)
  
  // Public API - Storage
  static Future<String> uploadIconImage(...)
  static Future<String> uploadThumbnail(...)
}
```

#### Service Design Patterns
- **Static methods:** No instantiation required
- **Future-based:** All async operations return Futures
- **Stream-based:** Real-time data via Streams
- **Error propagation:** Throws exceptions for error handling

#### EditorStorage Service
```dart
class EditorStorage {
  static Future<void> saveState(EditorState state)
  static Future<EditorState?> loadState()
  static Future<void> clearState()
}
```

Purpose: Persist editor state across app restarts

### Data Layer

#### Firebase Firestore Schema
```
users/
  {userId}/
    displayName: string
    email: string
    plan: string
    importsUsed: number
    createdAt: timestamp

packs/
  {packId}/
    name: string
    description: string
    ownerId: string
    isPublic: boolean
    price: number
    createdAt: timestamp
    
    icons/
      {iconId}/
        name: string
        editorState: map
        imageUrl: string
        createdAt: timestamp
```

#### SharedPreferences Schema
```
Keys:
- 'isLoggedIn': bool
- 'displayName': string
- 'userEmail': string
- 'userPasswordHash': string
- 'editorState': JSON string
- 'importsUsed': int
```

#### Firebase Storage Structure
```
icons/
  {userId}/
    {iconId}.png

thumbnails/
  {userId}/
    {iconId}_thumb.png
```

---

## Component Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                          IconStudioPro                        │
│                         (MaterialApp)                         │
└────────────────────┬─────────────────────────────────────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │      AuthGate         │
         │  (Route Controller)   │
         └───────────┬───────────┘
                     │
          ┌──────────┴──────────┐
          │                     │
          ▼                     ▼
    ┌──────────┐         ┌───────────┐
    │AuthScreen│         │StudioPage │
    └──────────┘         └─────┬─────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
              ▼                ▼                ▼
        ┌──────────┐    ┌──────────┐    ┌──────────┐
        │ Sliders  │    │ Shader   │    │ Export   │
        │          │    │ Preview  │    │ Button   │
        └──────────┘    └──────────┘    └──────────┘
              │                │                │
              └────────────────┼────────────────┘
                               │
                               ▼
                      ┌────────────────┐
                      │  EditorState   │
                      │  (Immutable)   │
                      └────────────────┘
                               │
                ┌──────────────┼──────────────┐
                │              │              │
                ▼              ▼              ▼
         ┌──────────┐   ┌──────────┐  ┌──────────┐
         │ Firebase │   │  Editor  │  │  Export  │
         │ Service  │   │ Storage  │  │ Service  │
         └──────────┘   └──────────┘  └──────────┘
```

---

## Data Flow

### Editor Parameter Update Flow
```
1. User drags slider
   │
   ├─▶ Slider.onChanged callback
   │
   ├─▶ _updateState(editorState.copyWith(param: newValue))
   │
   ├─▶ setState(() { editorState = newState; })
   │
   ├─▶ Widget tree rebuilds
   │
   ├─▶ ShaderBuilder receives new uniforms
   │
   ├─▶ Shader recompiles with new values
   │
   ├─▶ Canvas repaints
   │
   └─▶ EditorStorage.saveState(newState) [async]
```

### Image Import Flow
```
1. User taps "Import Image"
   │
   ├─▶ FilePicker.platform.pickFiles(type: image)
   │
   ├─▶ Validate file (size, format)
   │
   ├─▶ Read file bytes (Uint8List)
   │
   ├─▶ _updateState(editorState.copyWith(userImageBytes: bytes))
   │
   ├─▶ Shader receives new texture sampler
   │
   └─▶ Preview updates with new image
```

### Export Flow
```
1. User taps "Export Icon"
   │
   ├─▶ Capture RepaintBoundary as ui.Image (pixelRatio: 3.0)
   │
   ├─▶ Convert to PNG ByteData
   │
   ├─▶ Platform-specific export:
   │   │
   │   ├─▶ [Mobile] Write to file system
   │   │   └─▶ Show file location
   │   │
   │   └─▶ [Web] Create blob and download
   │       └─▶ Trigger browser download
   │
   └─▶ Show success message
```

### Authentication Flow
```
1. User enters credentials
   │
   ├─▶ Validate input (email format, password length)
   │
   ├─▶ Firebase signIn/signUp API call
   │
   ├─▶ [Sign-up only] Create user profile in Firestore
   │
   ├─▶ Update local AuthState
   │
   ├─▶ Persist to SharedPreferences
   │
   ├─▶ AuthGate detects state change
   │
   └─▶ Navigate to StudioPage
```

### Pack Publishing Flow
```
1. User taps "Publish Pack"
   │
   ├─▶ Show price/description dialog
   │
   ├─▶ User confirms
   │
   ├─▶ Upload pack thumbnail to Storage
   │
   ├─▶ Get public download URL
   │
   ├─▶ Update pack document in Firestore:
   │   {
   │     isPublic: true,
   │     price: X,
   │     thumbnailUrl: url
   │   }
   │
   ├─▶ Pack appears in marketplace
   │
   └─▶ Show success message
```

---

## State Management

### EditorState (Immutable Value Object)
```dart
class EditorState {
  final double scale;
  final double rotation;
  // ... 9 parameters total
  final Uint8List? userImageBytes;
  
  // Constructor with defaults
  EditorState({
    this.scale = 50,
    // ...
  });
  
  // Immutable update method
  EditorState copyWith({
    double? scale,
    // ...
  }) => EditorState(
    scale: scale ?? this.scale,
    // ...
  );
}
```

**Benefits:**
- Predictable state updates
- Easy to serialize/deserialize
- No accidental mutations
- Efficient change detection

### AuthState (ChangeNotifier)
```dart
class AuthState extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _displayName = '';
  
  bool get isLoggedIn => _isLoggedIn;
  String get displayName => _displayName;
  
  Future<void> signIn(...) async {
    // Update state
    _isLoggedIn = true;
    _displayName = name;
    
    // Persist
    await _saveToPrefs();
    
    // Notify listeners
    notifyListeners();
  }
}
```

**Pattern:** Observer pattern via ChangeNotifier

### State Persistence Strategy
```dart
// Save state after each change
void _updateState(EditorState newState) {
  setState(() {
    editorState = newState;
  });
  EditorStorage.saveState(newState);  // Fire and forget
}

// Load state on app start
@override
void initState() {
  super.initState();
  _loadState();
}

Future<void> _loadState() async {
  final saved = await EditorStorage.loadState();
  if (saved != null) {
    setState(() {
      editorState = saved;
    });
  }
}
```

---

## Module Breakdown

### Core Modules

#### 1. main.dart (Editor Core)
**Lines of Code:** ~800  
**Responsibilities:**
- App initialization
- Editor UI
- Parameter controls
- Shader integration
- Export coordination

**Key Classes:**
- `IconStudioPro` — App root
- `StudioPage` — Editor interface
- `EditorState` — Immutable state

#### 2. auth_screen.dart (Authentication)
**Lines of Code:** ~400  
**Responsibilities:**
- Sign-up flow
- Sign-in flow
- Password validation
- Session persistence

**Key Classes:**
- `AuthGate` — Route guard
- `AuthState` — Auth state management
- `SignUpScreen` — Registration UI
- `SignInScreen` — Login UI

#### 3. firebase_service.dart (Backend API)
**Lines of Code:** ~300  
**Responsibilities:**
- Firebase initialization
- Authentication API
- Firestore operations
- Storage operations

**Key Classes:**
- `FirebaseService` — Static API wrapper

#### 4. pack_editor_screen.dart (Pack Management)
**Lines of Code:** ~600  
**Responsibilities:**
- Pack creation/editing
- Icon management
- Publishing to marketplace
- Icon editor integration

**Key Classes:**
- `PackEditorScreen` — Pack UI
- `IconEditorSheet` — Modal editor

#### 5. editor_storage.dart (Persistence)
**Lines of Code:** ~100  
**Responsibilities:**
- Serialize EditorState to JSON
- Save to SharedPreferences
- Load from SharedPreferences

**Key Classes:**
- `EditorStorage` — Static storage API

#### 6. export_helper.dart (Export Coordination)
**Lines of Code:** ~50  
**Responsibilities:**
- Platform detection
- Export API abstraction

#### 7. export_io.dart (Mobile Export)
**Lines of Code:** ~80  
**Responsibilities:**
- File system access
- PNG encoding
- File writing

#### 8. export_web.dart (Web Export)
**Lines of Code:** ~70  
**Responsibilities:**
- Blob creation
- Browser download trigger

#### 9. app_colors.dart (Design System)
**Lines of Code:** ~30  
**Responsibilities:**
- Color constants
- Theme consistency

**Constants:**
```dart
class AppColors {
  static const background = Color(0xFF0A0E27);
  static const panel = Color(0xFF1A1F3A);
  static const panelBorder = Color(0xFF2A2F4A);
  static const gold = Color(0xFFFFD700);
  static const textPrimary = Color(0xFFE0E0E0);
  static const textSecondary = Color(0xFFA0A0A0);
}
```

---

## Design Patterns

### 1. Value Object Pattern
**Usage:** EditorState  
**Purpose:** Immutable data containers

```dart
class EditorState {
  final double scale;
  // ... immutable fields
  
  EditorState copyWith({...}) => EditorState(...);
}
```

### 2. Service Locator Pattern
**Usage:** FirebaseService  
**Purpose:** Centralized service access

```dart
class FirebaseService {
  static final _auth = FirebaseAuth.instance;
  static Future<void> signIn(...) => _auth.signIn(...);
}
```

### 3. Observer Pattern
**Usage:** AuthState (ChangeNotifier)  
**Purpose:** Reactive state updates

```dart
class AuthState extends ChangeNotifier {
  void updateState() {
    // ... change state
    notifyListeners();  // Notify observers
  }
}
```

### 4. Strategy Pattern
**Usage:** Export system  
**Purpose:** Platform-specific implementations

```dart
// Interface (implied by shared method signature)
Future<void> exportIcon(boundary);

// Strategies
export_io.dart     // Mobile strategy
export_web.dart    // Web strategy
```

### 5. Builder Pattern
**Usage:** ShaderBuilder  
**Purpose:** Declarative shader setup

```dart
ShaderBuilder(
  assetKey: 'shader.frag',
  (context, shader, child) {
    // Configure shader
    return CustomPaint(painter: ShaderPainter(shader));
  },
)
```

### 6. Repository Pattern
**Usage:** EditorStorage  
**Purpose:** Abstract persistence layer

```dart
class EditorStorage {
  static Future<void> saveState(state);
  static Future<EditorState?> loadState();
}
```

---

## Security Architecture

### Authentication Security

#### Password Handling
```dart
// SHA-256 hashing (local auth only)
String _hashPassword(String password) {
  final bytes = utf8.encode(password);
  return sha256.convert(bytes).toString();
}
```

**Note:** Firebase Auth uses industry-standard bcrypt for server-side storage

#### Session Management
- Tokens stored in Firebase SDK (secure)
- Local session flag in SharedPreferences
- Auto-logout on auth state change

### Firestore Security Rules
```javascript
// User data isolation
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}

// Pack access control
match /packs/{packId} {
  allow read: if resource.data.isPublic == true 
              || request.auth.uid == resource.data.ownerId;
  allow write: if request.auth.uid == resource.data.ownerId;
}
```

**Principles:**
- User can only read/write their own data
- Public packs readable by all
- Only pack owner can modify pack

### Storage Security Rules
```javascript
// User-scoped uploads
match /icons/{userId}/{allPaths=**} {
  allow read: if true;  // Public read
  allow write: if request.auth.uid == userId;  // Owner only write
}
```

### Input Validation
```dart
// Email validation
final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

// Parameter bounds checking
double clamp(double value, double min, double max) {
  return value.clamp(min, max);
}
```

---

## Performance Architecture

### Rendering Pipeline Optimization

#### 1. Shader Compilation Caching
- Shader compiled once on first load
- Reused for all subsequent frames
- No runtime compilation overhead

#### 2. Texture Streaming
```dart
// Image loaded once
final img = await decodeImageFromList(bytes);
shader.setImageSampler(0, img);

// Reused across frames (no re-upload)
```

#### 3. Frame Rate Management
```dart
// Ticker for 60 FPS rendering
class _StudioPageState extends State<StudioPage> 
    with SingleTickerProviderStateMixin {
  
  late Ticker _ticker;
  
  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      setState(() {
        _time = elapsed.inMilliseconds / 1000.0;
      });
    })..start();
  }
}
```

### Memory Management

#### Image Lifecycle
```dart
// Load
Uint8List bytes = file.readAsBytes();
ui.Image image = await decodeImageFromList(bytes);

// Use
shader.setImageSampler(0, image);

// Dispose
@override
void dispose() {
  image.dispose();
  _ticker.dispose();
  super.dispose();
}
```

#### State Persistence Strategy
- Save to disk asynchronously (non-blocking)
- Debounce saves (avoid excessive writes)
- Load once on app start

### Build Size Optimization

#### Asset Minimization
```yaml
flutter:
  assets:
    - assets/icons/  # Only required icons
  
  shaders:
    - shaders/diamond_master.frag  # Single shader
```

#### Tree Shaking
- Release builds automatically strip unused code
- Const constructors enable more aggressive optimization
- Final fields enable compiler optimizations

### Network Optimization

#### Firebase Query Optimization
```dart
// Limit query results
_db.collection('packs')
  .where('isPublic', isEqualTo: true)
  .limit(20)
  .get();

// Use streams for real-time updates (efficient)
_db.collection('packs').snapshots()
```

#### Image Upload Optimization
```dart
// Compress before upload
final compressed = await compressImage(bytes);

// Upload with metadata
await _storage.ref('icons/$userId/$iconId.png')
  .putData(compressed, SettableMetadata(
    contentType: 'image/png',
    cacheControl: 'public, max-age=31536000',
  ));
```

---

## Scalability Considerations

### Current Architecture Limits
- **User scale:** Unlimited (Firebase Auth)
- **Storage scale:** 5 GB free, then pay-as-you-go
- **Firestore reads:** 50k/day free, then $0.06/100k
- **Concurrent users:** No hard limit

### Future Scalability Enhancements
1. **CDN Integration** — Serve images via Cloudflare
2. **Image Optimization** — Server-side WebP conversion
3. **Caching Layer** — Redis for frequently accessed data
4. **Background Processing** — Cloud Functions for heavy tasks
5. **Load Balancing** — Multiple Firebase projects

---

## Deployment Architecture

### Development Environment
```
Local Machine
├─ Flutter SDK (stable channel)
├─ Android Studio / VS Code
├─ Android Emulator / iOS Simulator
└─ Firebase Emulator Suite (optional)
```

### Staging Environment
```
GitHub Actions CI
├─ Ubuntu runners (Android, Web)
├─ macOS runners (iOS)
├─ Automated testing
└─ Artifact generation
```

### Production Environment
```
Firebase Console
├─ Hosting (Web builds)
├─ Authentication (user management)
├─ Firestore (database)
├─ Storage (file hosting)
└─ Analytics (usage tracking)

App Stores
├─ Google Play Store (Android)
└─ Apple App Store (iOS)
```

---

## Architecture Evolution

### Version 1.0 (Current)
- Single-shader editor
- Local + Firebase auth
- Basic pack management
- Manual export

### Version 1.1 (Planned)
- Multiple shader effects
- Social sharing
- Batch export
- Enhanced marketplace

### Version 2.0 (Future)
- Real-time collaboration
- Cloud rendering
- AI-powered suggestions
- Plugin system

---

## Conclusion

Iconic Studio Pro's architecture is designed for:
- **Maintainability:** Clear module boundaries
- **Testability:** Isolated components
- **Scalability:** Firebase backend
- **Performance:** Optimized rendering
- **Security:** Defense-in-depth approach

The architecture balances simplicity with flexibility, enabling rapid iteration while maintaining code quality.

---

**Document Version:** 1.0  
**Last Review Date:** May 6, 2026  
**Architecture Owner:** Development Team
