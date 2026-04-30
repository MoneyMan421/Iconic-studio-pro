# Online Store Platform Report

*Iconic Studio Pro — April 2026*

---

## Best Spot to Open the Store

**Recommendation: Gumroad (launch) → Lemon Squeezy (scale)**

Both are built for digital creators, handle global taxes automatically, and can go live
the same day. No monthly fee to start.

---

## Platform Comparison

| Platform | Fee | Best For |
|---|---|---|
| **Gumroad** | 10 % per sale (free plan) | Quickest launch, built-in audience discovery |
| **Lemon Squeezy** | 5 % + $0.50 per sale | Software licenses, cleaner storefront |
| **Paddle** | 5 % + $0.50 per sale | Global tax compliance, larger scale |
| **Shopify** | $29–$299 / mo | Full branded store, physical + digital |

---

## Why Gumroad First

- Zero upfront cost — pay only when you sell.
- Supports digital downloads, subscriptions, and pay-what-you-want pricing.
- Marketplace discovery brings buyers without ad spend.
- One-click migration to Lemon Squeezy later if license-key management is needed.

---

## In-App Purchases (Separate Track)

For subscriptions sold inside the app (Pro Monthly / Pro Lifetime), the stores require
native billing — the 30 % platform cut cannot be avoided there. Use **RevenueCat**
(`purchases_flutter`) to manage both App Store and Google Play billing from a single
Flutter SDK.

---

## Next Steps

1. Open a Gumroad account and list the first product (icon pack or Pro license bundle).
2. Point the app's settings/about screen to the store URL.
3. Integrate RevenueCat for the in-app paywall when ready to publish to the stores.
