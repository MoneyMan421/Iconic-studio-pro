# Iconic Studio Pro — Remaining Issues to Fix

## 🔴 Critical / Go-Live Blocking

### 1. Payment SDK not integrated
**File:** `lib/main.dart` → `PaywallModal._handleUpgrade()`

The paywall tier buttons currently show a coming-soon SnackBar.
No real payment processing occurs. A payment SDK must be integrated before
the app can monetise.

**Recommended approach:**
- Add [RevenueCat](https://www.revenuecat.com/docs/flutter) (`purchases_flutter`)
- Create products in App Store Connect / Google Play Console
- Replace the TODO block in `_handleUpgrade()` with `Purchases.purchasePackage()`

---

### 2. Firebase Auth migration incomplete
**File:** `lib/auth_screen.dart`

Authentication is currently local-only (SharedPreferences + SHA-256 hash).
`firebase_auth ^4.20.0` is already a dependency but is unused.

**Steps:**
1. Run `flutterfire configure --project=YOUR_PROJECT_ID` to regenerate `lib/firebase_options.dart`
2. Enable Email/Password auth in Firebase Console
3. Replace `signUp()` / `login()` / `logout()` in `AuthState` with:
   - `FirebaseAuth.instance.createUserWithEmailAndPassword()`
   - `FirebaseAuth.instance.signInWithEmailAndPassword()`
   - `FirebaseAuth.instance.signOut()`
4. Drive `AuthGate` from `FirebaseAuth.instance.authStateChanges()` stream

---

### 3. `lib/firebase_options.dart` has placeholder values
**File:** `lib/firebase_options.dart`

All API keys are `'YOUR_*'` placeholders. Firebase will throw at runtime.

**Fix:**
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```
Then place `google-services.json` in `android/app/`.

---

## 🟡 Enhancement Backlog

### 4. Real FPS measurement ✅ Fixed
Was hard-coded to `'120'`. Now uses a live `Ticker`-based counter.

### 5. Paywall "Upgrade Now" button ✅ Partially fixed
Was a no-op. Now shows tier options + coming-soon feedback.
Full fix requires payment SDK (see item 1 above).

### 6. AuthGate rebuild after login ✅ Fixed
Gate now correctly re-evaluates via `onAuthenticated()` callback.

---

## 🟢 Previously Fixed

| # | Issue |
|---|---|
| 1 | Tests pump `StudioPage` directly, not `AuthGate` |
| 2 | Stale `shaders/lib/main.dart` deleted (was causing 30 analyzer errors) |
| 3 | FPS hard-coded value replaced with real Ticker measurement |
| 4 | `withOpacity()` → `withValues(alpha:)` throughout |
| 5 | `EditorStorage` fully implemented (was a stub) |
| 6 | `AppColors.error` constant added; no raw Color literals |
| 7 | `PaywallModal` no longer silently does nothing |
| 8 | Widget test suite expanded to 9 tests |
