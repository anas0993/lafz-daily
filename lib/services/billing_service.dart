import 'package:flutter/foundation.dart';

/// Stub: billing disabled in the clean build. Same public API, no plugin.
class BillingService {
  BillingService._();
  static final BillingService instance = BillingService._();

  final ValueNotifier<bool> isPro = ValueNotifier(false);

  Future<void> init() async {}
  Future<void> restore() async {}

  bool get canBuy => false;
  Future<bool> buyPro() async => false;
  String? get priceString => null;
}
