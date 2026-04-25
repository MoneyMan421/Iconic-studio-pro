# Iconic Studio Pro – Issues to Fix

Identified from CI failure logs (`flutter analyze --fatal-infos`) and code review.
Last updated: 2026-04-25

---

## 1. Stray file: `shaders/lib/main.dart`

**Severity:** Critical (causes ~30 analyzer errors)  
**File:** `shaders/lib/main.dart`  
**Problem:** A stale copy of an old version of `main.dart` was committed inside the `shaders/` directory. Flutter's analyzer recursively walks all `.dart` files it can reach and picks this file up. Because it is incomplete/outdated (missing closing braces, duplicate class names, wrong inheritance), it produces a cascade of errors:
- `class_in_class` – classes declared inside other classes
- `cast_to_non_type` – `RenderRepaintBoundary` not recognised (name clash with duplicated classes)
- `undefined_method` – `PaywallModal`, `PreviewCanvas` called on wrong type
- `read_potentially_unassigned_final` – final variables referenced out of scope
- `referenced_before_declaration` – local helpers used before closure declaration
- `invalid_use_of_covariant`, `not_a_type`, `duplicate_definition`, and more

**Fix:** Delete `shaders/lib/main.dart` entirely.

---

## 2. Test file uses non-existent class `IconicStudioApp`

**Severity:** High (compile error, blocks test job)  
**File:** `test/widget_test.dart`, lines 11 and 34  
**Problem:** The test pumps `const IconicStudioApp()` but the root widget is named `IconStudioPro`. This produces:
```
error • The name 'IconicStudioApp' isn't a class • test/widget_test.dart:11 • creation_with_non_type
error • The name 'IconicStudioApp' isn't a class • test/widget_test.dart:34 • creation_with_non_type
```
Additionally, even if the name were corrected, `IconStudioPro` wraps everything in `AuthGate`, which reads SharedPreferences and shows the **login screen** — not the studio UI — so assertions like `find.text('Export Icon')` would fail at runtime.

**Fix:** Replace `const IconicStudioApp()` with `MaterialApp(home: const StudioPage())` so the studio page is rendered directly, bypassing the auth gate.

---

## 3. `const` on `MaterialApp` containing a non-const `ShaderBuilder`

**Severity:** High (compile error)  
**File:** `test/widget_test.dart`, line ~47  
**Problem:** The `ShaderBuilder` test wraps the widget in `const MaterialApp(...)`. Because `ShaderBuilder` receives a function literal (a closure), the entire widget tree cannot be `const`:
```
error • Arguments of a constant creation must be constant expressions • test/widget_test.dart:51 • const_with_non_constant_argument
```

**Fix:** Remove the `const` keyword from the `MaterialApp` constructor in that test case.

---

## 4. Deprecated `Color.withOpacity()` calls (6 occurrences)

**Severity:** Medium (deprecation warning – fails `--fatal-infos` on future Flutter stable versions; already a lint hint)  
**Files & lines:**

| File | Line | Call |
|---|---|---|
| `lib/main.dart` | 86 | `AppColors.gold.withOpacity(0.2)` |
| `lib/main.dart` | 340 | `AppColors.gold.withOpacity(0.15)` |
| `lib/main.dart` | 342 | `AppColors.gold.withOpacity(0.3)` |
| `lib/main.dart` | 415 | `AppColors.textSecondary.withOpacity(0.6)` |
| `lib/main.dart` | 680 | `AppColors.gold.withOpacity(0.1)` |
| `lib/auth_screen.dart` | 508 | `const Color(0xFFD4AF37).withOpacity(0.5)` |

**Problem:** `Color.withOpacity()` was deprecated in Flutter 3.27. The replacement is `Color.withValues(alpha: value)`.

**Fix:** Replace each `withOpacity(x)` call with `withValues(alpha: x)`.

---

## 5. `RenderRepaintBoundary` cast error in `lib/main.dart`

**Severity:** Medium (may be a side-effect of issue #1; verify after fix)  
**File:** `lib/main.dart`, line 151  
**Problem:** The analyzer reports:
```
error • The name 'RenderRepaintBoundary' isn't a type • lib/main.dart:151 • cast_to_non_type
```
`RenderRepaintBoundary` is defined in `package:flutter/rendering.dart` (re-exported by `package:flutter/material.dart`). The error is likely a namespace confusion caused by the duplicate class definitions in `shaders/lib/main.dart` (issue #1).

**Fix:** Delete `shaders/lib/main.dart` (issue #1). If the error persists, add an explicit import:
```dart
import 'package:flutter/rendering.dart';
```

---

## Summary

| # | File | Severity | Action |
|---|---|---|---|
| 1 | `shaders/lib/main.dart` | 🔴 Critical | Delete the file |
| 2 | `test/widget_test.dart` lines 11, 34 | 🔴 High | Replace `IconicStudioApp` → `MaterialApp(home: StudioPage())` |
| 3 | `test/widget_test.dart` line ~47 | 🔴 High | Remove `const` from `MaterialApp` in ShaderBuilder test |
| 4 | `lib/main.dart` (×5), `lib/auth_screen.dart` (×1) | 🟡 Medium | Replace `withOpacity(x)` → `withValues(alpha: x)` |
| 5 | `lib/main.dart` line 151 | 🟡 Medium | Likely resolved by fix #1; add explicit import if not |
