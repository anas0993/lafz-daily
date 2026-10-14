import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Google Play Billing for Word Daily Premium subscriptions.
/// Products (create these in Play Console):
/// - premium_3mo: $10 for 3 months
/// - premium_6mo: $15 for 6 months
class BillingService {
  BillingService._();
  static final BillingService instance = BillingService._();

  final ValueNotifier<bool> isPro = ValueNotifier(false);
  final ValueNotifier<bool> isAvailable = ValueNotifier(false);
  
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  static const String product3mo = 'premium_3mo';
  static const String product6mo = 'premium_6mo';
  static const Set<String> _productIds = {product3mo, product6mo};
  
  List<ProductDetails> products = [];
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    
    try {
      isAvailable.value = await _iap.isAvailable();
      if (!isAvailable.value) return;

      // Listen to purchase updates
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (e) => debugPrint('Billing error: $e'),
      );

      // Load products
      final response = await _iap.queryProductDetails(_productIds);
      if (response.error == null) {
        products = response.productDetails;
      }

      // Restore previous purchases
      await restore();
    } catch (e) {
      debugPrint('Billing init error: $e');
      isAvailable.value = false;
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _verifyAndGrant(purchase);
      }
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _verifyAndGrant(PurchaseDetails purchase) async {
    // TODO: Server-side verification via Supabase
    // For now, grant locally and sync to backend
    if (purchase.productID == product3mo || purchase.productID == product6mo) {
      isPro.value = true;
      // TODO: Call BackendService to record premium subscription
    }
  }

  Future<void> restore() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('Restore error: $e');
    }
  }

  bool get canBuy => isAvailable.value && products.isNotEmpty;

  ProductDetails? getProduct(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  String? priceFor(String id) => getProduct(id)?.price;

  Future<bool> buy(String productId) async {
    final product = getProduct(productId);
    if (product == null) return false;
    
    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      // Subscriptions use buyNonConsumable
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('Buy error: $e');
      return false;
    }
  }

  // Legacy API compatibility
  Future<bool> buyPro() => buy(product3mo);
  String? get priceString => priceFor(product3mo);

  void dispose() {
    _subscription?.cancel();
  }
}
