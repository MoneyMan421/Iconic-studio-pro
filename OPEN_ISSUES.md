# Open Issues Requiring Product Decisions

This document tracks remaining open issues from `issues_blocking_go_live.py` that require product/business decisions rather than technical fixes.

**Last Updated:** 2026-05-17  
**Status:** 3 open issues requiring product decisions

---

## Issue #9: Paywall Upgrade Button Does Nothing

**Location:** `lib/main.dart` – line ~128 (PaywallModal)  
**Severity:** High - Business Critical  
**Type:** Missing Payment Integration

### Description
The "Upgrade Now" button in the PaywallModal only closes the dialog (`Navigator.pop(context)`). No payment SDK is integrated, no Pro subscription flag is set, and no features are actually unlocked.

### Impact
- Users cannot actually purchase Pro subscriptions
- Monetization is completely blocked
- False advertising (showing pricing but not accepting payment)

### Recommended Solutions

**Option 1: Integrate Payment SDK (Recommended)**
- Integrate `in_app_purchase` package for mobile (iOS/Android)
- Integrate Stripe or similar for web payments
- Add subscription state management
- Unlock features based on subscription status

**Option 2: Remove Paywall Temporarily**
- Remove or disable the paywall UI
- Make all features free during beta/MVP
- Add payment integration later

**Decision Required:** Which monetization strategy to pursue?

---

## Issue #12: SVG Upload Advertised but Not Supported

**Location:** `lib/main.dart` – PreviewCanvas upload zone, line ~560  
**Severity:** Medium - UX/Trust Issue  
**Type:** Feature Gap / Misleading UI

### Description
The upload zone text reads "PNG, SVG, or JPG (max. 5 MB)" but:
- `FilePicker.platform.pickFiles(type: FileType.image)` doesn't include SVG on most platforms
- Even if selected, `Image.memory()` cannot decode SVG bytes (requires vector rendering)

### Impact
- Misleading user expectations
- Negative user experience if they try to upload SVG
- Trust/credibility issue

### Recommended Solutions

**Option 1: Add SVG Support (Feature Enhancement)**
- Already have `flutter_svg: ^2.0.10+1` in dependencies
- Implement SVG decoding and rendering
- Convert SVG to raster for shader processing
- ~2-3 days development + testing

**Option 2: Remove SVG from Label (Quick Fix)**
- Change text to "PNG or JPG (max. 5 MB)"
- One-line change, zero risk
- Ship immediately

**Decision Required:** Is SVG support a priority feature or should we remove it from UI?

---

## Issue #13: Cloud Sync Advertised but Not Implemented

**Location:** `lib/main.dart` – PaywallModal._buildTier(), line ~708  
**Severity:** High - False Advertising  
**Type:** Missing Feature

### Description
The Pro Monthly and Pro Lifetime tiers both list "Cloud sync" as an included feature:
```dart
_buildTier('Pro Monthly', '\$4.99/mo', ['Unlimited imports', 'All shaders', 'Cloud sync'])
```

However:
- No sync functionality exists anywhere in the codebase
- EditorState is only persisted locally via SharedPreferences
- No network sync API, no conflict resolution, no server-side storage

### Impact
- **Legal Risk:** Advertising a feature that doesn't exist could be considered false advertising
- Users who upgrade expecting cloud sync will be disappointed
- Refund requests likely
- Potential app store policy violation

### Recommended Solutions

**Option 1: Remove from Feature List (Immediate)**
- Remove "Cloud sync" from both tier descriptions
- Ship fix immediately to avoid legal/trust issues
- Can add feature later

**Option 2: Implement Cloud Sync (Long-term)**
- Already have Firebase dependencies
- Use Firestore for cross-device state sync
- Implement conflict resolution
- ~5-7 days development + testing
- Requires backend architecture decisions

**Option 3: Replace with Existing Feature**
- Change "Cloud sync" to "Cloud backup" (if Firebase is available)
- Or another actually-implemented feature
- Still removes false advertising

**Decision Required:** Immediate removal or commit to implementation timeline?  
**Recommendation:** Remove immediately (Option 1) to eliminate legal/trust risk, plan implementation separately.

---

## Additional Repository Issues Found

### Issue #19: Stray Zip File in Repository Root
**Status:** FIXED  
**Action Taken:** Removed `b_XHd7BxE0bHP (5).zip` and added `*.zip` to `.gitignore`

### Issue #20: Incomplete .gitignore
**Status:** FIXED  
**Action Taken:** Added patterns for archives (`*.zip`, `*.tar.gz`), Python cache, and other common temp files

---

## Summary

**Issues Fixed Today:** 7 technical issues + 2 repository housekeeping issues  
**Issues Requiring Decisions:** 3 product/business issues

**Critical Path:** Issues #9 and #13 should be addressed before any marketing or public launch due to false advertising concerns.

**Next Steps:**
1. Product owner reviews and decides on Issues #9, #12, #13
2. If removing features from UI (recommended): ~1 hour to implement
3. If implementing features: plan sprints accordingly
