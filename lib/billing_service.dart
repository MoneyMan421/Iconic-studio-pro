import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Lightweight wrapper around [InAppPurchase] that exposes only the surfaces
/// needed by the UI:
///
/// * [products] — list of purchasable [BillingProduct]s, populated once the
///   store connection is ready.
/// * [isPro] — a [ValueNotifier] that is `true` whenever the user owns a Pro
///   entitlement (monthly or lifetime).
/// * [buy] — initiates a purchase flow for the given [BillingProduct].
class BillingProduct {
  final String title;
  final String price;
  final ProductDetails _details;

  const BillingProduct._({
    required this.title,
    required this.price,
    required ProductDetails details,
  }) : _details = details;
}

class BillingService {
  BillingService._();

  static final BillingService instance = BillingService._();

  static const String _monthlyId = 'pro_monthly';
  static const String _lifetimeId = 'pro_lifetime';
  static const Set<String> _productIds = {_monthlyId, _lifetimeId};

  final InAppPurchase _iap = InAppPurchase.instance;

  final ValueNotifier<bool> isPro = ValueNotifier(false);

  List<BillingProduct> products = [];

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _initialized = false;

  /// Call once (e.g. in [State.initState]) to connect to the store and start
  /// listening for purchase updates.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final available = await _iap.isAvailable();
    if (!available) return;

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (_) {},
    );

    await _loadProducts();

    // Restore any previously completed purchases so that reinstalls / new
    // devices are handled automatically.
    await _iap.restorePurchases();
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails(_productIds);
    products = response.productDetails.map((d) {
      return BillingProduct._(
        title: d.title,
        price: d.price,
        details: d,
      );
    }).toList();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) continue;

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (_productIds.contains(purchase.productID)) {
          isPro.value = true;
        }
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.error) {
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
      }
    }
  }

  /// Initiates a purchase for [product].
  Future<void> buy(BillingProduct product) async {
    final param = PurchaseParam(productDetails: product._details);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  /// Cancels the purchase stream subscription.
  ///
  /// This is provided for testing purposes. In production the singleton lives
  /// for the lifetime of the app and does not need explicit cleanup.
  void dispose() {
    _subscription?.cancel();
    isPro.dispose();
  }
}
