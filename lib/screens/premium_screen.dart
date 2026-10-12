import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/billing_service.dart';

/// Premium via Google Play Billing.
/// Products: premium_3mo ($10), premium_6mo ($15)
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});
  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _buying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    BillingService.instance.init();
  }

  Future<void> _buy(String productId) async {
    setState(() { _buying = true; _error = null; });
    final ok = await BillingService.instance.buy(productId);
    if (mounted) {
      setState(() {
        _buying = false;
        if (!ok) _error = 'Purchase failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;
    final billing = BillingService.instance;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(s.get('premiumTitle'))),
      body: ValueListenableBuilder<bool>(
        valueListenable: billing.isPro,
        builder: (context, isPro, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Icon(Icons.workspace_premium_rounded, size: 80, color: Colors.amber.shade700),
            const SizedBox(height: 16),
            Text(
              s.get('premiumTitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              s.get('premiumFeatures'),
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            if (isPro) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(child: Text(s.get('proActive'), style: const TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
            ] else ...[
              // 3-month plan
              _PlanCard(
                title: s.get('package3mo'),
                price: billing.priceFor(BillingService.product3mo) ?? '\$10',
                features: s.get('premiumFeatures'),
                buying: _buying,
                onBuy: () => _buy(BillingService.product3mo),
              ),
              const SizedBox(height: 12),
              // 6-month plan
              _PlanCard(
                title: s.get('package6mo'),
                price: billing.priceFor(BillingService.product6mo) ?? '\$15',
                features: s.get('premiumFeatures'),
                badge: s.get('bestValue'),
                buying: _buying,
                onBuy: () => _buy(BillingService.product6mo),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 16),
              // Restore
              TextButton(
                onPressed: () => billing.restore(),
                child: Text(s.get('restore')),
              ),
            ],

            const SizedBox(height: 16),
              Text(
                s.get('premiumNote'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.features,
    required this.buying,
    required this.onBuy,
    this.badge,
  });

  final String title;
  final String price;
  final String features;
  final bool buying;
  final VoidCallback onBuy;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.amber.shade700, borderRadius: BorderRadius.circular(8)),
                    child: Text(badge!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(features, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(price, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: scheme.primary)),
                const Spacer(),
                FilledButton(
                  onPressed: buying ? null : onBuy,
                  child: buying
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(MaterialLocalizations.of(context).continueButtonLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
