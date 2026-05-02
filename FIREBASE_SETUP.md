# Firebase Setup — Iconic Studio Pro

## Step 1 — Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

## Step 2 — Connect your Firebase project
```bash
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```
This auto-generates `lib/firebase_options.dart` with your real keys.

## Step 3 — Drop google-services.json
Download `google-services.json` from Firebase Console:
- Firebase Console → Project Settings → Your Apps → Android → Download
- Place it at: `android/app/google-services.json`

## Step 4 — Enable Firebase services in console
Go to Firebase Console and enable:
- ✅ Authentication → Email/Password
- ✅ Firestore Database → Start in production mode
- ✅ Storage → Start in production mode

## Step 5 — Set Firestore rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /packs/{packId} {
      allow read: if resource.data.isPublic == true || request.auth.uid == resource.data.ownerId;
      allow write: if request.auth != null && request.auth.uid == resource.data.ownerId;
      match /icons/{iconId} {
        allow read, write: if request.auth != null && request.auth.uid == get(/databases/$(database)/documents/packs/$(packId)).data.ownerId;
      }
    }
  }
}
```

## Step 6 — Set Storage rules
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /icons/{userId}/{allPaths=**} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /thumbnails/{userId}/{allPaths=**} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 7 — Run the app
```bash
flutter pub get
flutter run
```
