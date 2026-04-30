# Online Store Platform Report
*Prepared for: Iconic Studio Pro — April 2026*

---

## Executive Summary

This report evaluates the best platforms and strategies for launching an online store
for Iconic Studio Pro. Given that the product is a digital/creative tool with a
built-in in-app paywall (Pro Monthly / Pro Lifetime), the recommendations below cover
both **in-app commerce** and **standalone e-commerce storefronts** for merchandise,
licenses, and digital bundles.

---

## 1. In-App Store (Already Built-In)

**Current state:** Iconic Studio Pro already has a Pro paywall implemented in-app
(`lib/main.dart` / `lib/auth_screen.dart`). The natural next step is wiring this to a
real payment processor.

| Option | Pros | Cons |
|---|---|---|
| **RevenueCat** | Flutter-native SDK, handles Apple/Google billing, analytics, webhooks | Platform fees (15–30 % Apple/Google cut applies) |
| **Stripe** | Full control, web + mobile, no platform cut | Requires custom billing UI, not allowed for in-app digital goods on iOS |
| **Google Play Billing / App Store IAP** | Required for in-app purchases on respective stores | 15–30 % cut; separate APIs for each platform |

**Recommendation:** Use **RevenueCat** as the subscription management layer on top of
native IAP. It abstracts both App Store and Google Play billing and provides a clean
Flutter SDK (`purchases_flutter`).

---

## 2. Standalone Digital Storefront

For selling icon packs, shader presets, or a web license of Iconic Studio Pro outside
the app stores (avoiding the 30 % cut):

| Platform | Best For | Fee Structure |
|---|---|---|
| **Gumroad** | Solo creators, instant setup, digital downloads | Free plan (10 % fee); Creator plan $10/mo (5 % fee) |
| **Lemon Squeezy** | SaaS / software licenses, EU VAT handling | 5 % + $0.50 per transaction |
| **Paddle** | Global software sales, handles tax compliance | 5 % + $0.50 per transaction |
| **Shopify** | Full-featured storefront + physical merch | $29–$299/mo; 0.5–2 % transaction fee |

**Recommendation for digital downloads / licenses:** **Lemon Squeezy** or **Gumroad**.
Both are low-friction, handle global tax (VAT/GST), and take minutes to set up.

- **Lemon Squeezy** is preferred if you plan to sell software licenses (it has a built-in
  license key system).
- **Gumroad** is preferred if the priority is simplicity and brand reach via its
  marketplace discovery.

---

## 3. Physical Merchandise (Optional)

If branded merchandise (t-shirts, stickers, prints) is part of the roadmap:

| Platform | Notes |
|---|---|
| **Printful + Shopify** | Print-on-demand; no inventory risk |
| **Redbubble** | Zero setup; lower margins; good for art-focused audiences |
| **Fourthwall** | Creator-focused; integrates digital + physical in one shop |

**Recommendation:** **Fourthwall** — it supports both digital products and physical
merch in a single storefront, which is a clean fit for a creative-tool brand.

---

## 4. Top Overall Recommendation

| Goal | Platform |
|---|---|
| Monetise in-app (subscriptions) | **RevenueCat** + native IAP |
| Sell icon packs / shader presets online | **Gumroad** (quick start) or **Lemon Squeezy** (license keys) |
| Scale to a full branded store | **Shopify** |
| Sell physical + digital merch | **Fourthwall** |

For the **fastest time to revenue** with minimal overhead: set up a **Gumroad** or
**Lemon Squeezy** storefront first (same day), then layer in **RevenueCat** for the
in-app subscription as a follow-up sprint.

---

## 5. Key Next Steps

1. Decide on the product catalogue (subscription tiers, icon pack bundles, one-time
   licenses, physical merch — or a subset).
2. Choose a storefront from the table above.
3. Register a business entity / payment account if not already done.
4. Wire RevenueCat into the existing Flutter paywall for in-app purchases.
5. Add a "Buy" or "Shop" link to the app's about/settings screen pointing to the
   external storefront.

---

*This report lives in `deliverables/` and is not part of the shipped application.*
