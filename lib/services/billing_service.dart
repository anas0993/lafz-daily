import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'ads_service.dart';
import 'storage_service.dart';

/// One-time "Pro" purchase via Google Play Billing.
///
/// Product id must exist in the Play Console before release:
///   lafz_daily_pro  (one-time / non-consumable)
/// Until then the UI shows "not available" instead of crashing.
class BillingService {
  BillingService._();
  static final BillingService instance = BillingService._();

  static const String proProductId = 'lafz_daily_pro';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  bool _available = false;
  ProductDetails? _proProduct;
  bool _querying = false;

  final ValueNotifier<bool> isPro = ValueNotifier(false);

  Future<void> init() async {
    final store = StorageService.instance;
    final saved = store.getBool('is_pro') ?? false;
    isPro.value = saved;
    AdsService.instance.setPro(saved);

    _available = await _iap.isAvailable();
    if (!_available) {
      debugPrint('Billing not available on this device/store');
      return;
    }
    _sub = _iap.purchaseStream.listen(
      _onPurchases,
      onError: (e) => debugPrint('Purchase stream error: $e'),
    );
    await queryProducts();
    // Catch up on already-owned purchases (fresh installs / new devices).
    await _iap.restorePurchases();
  }

  Future<void> queryProducts() async {
    if (!_available || _querying) return;
    _querying = true;
    try {
      final resp =
          await _iap.queryProductDetails({proProductId});
      if (resp.productDetails.isNotEmpty) {
        _proProduct = resp.productDetails.first;
      } else {
        debugPrint('Pro product not found: ${resp.notFoundIDs}');
      }
    } catch (e) {
      debugPrint('queryProductDetails failed: $e');
    } finally {
      _querying = false;
    }
  }

  String? get priceString => _proProduct?.price;
  bool get canBuy => _available && _proProduct != null && !isPro.value;

  Future<bool> buyPro() async {
    final product = _proProduct;
    if (!_available || product == null || isPro.value) return false;
    final param = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() async {
    if (!_available) return;
    await _iap.restorePurchases();
  }

  Future<void> _onPurchases(List<PurchaseDetails> list) async {
    for (final p in list) {
      if (p.productID != proProductId) continue;
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        await _grantPro();
      }
      if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
    }
  }

  Future<void> _grantPro() async {
    isPro.value = true;
    AdsService.instance.setPro(true);
    await StorageService.instance.setBool('is_pro', true);
  }

  void dispose() => _sub?.cancel();
}
