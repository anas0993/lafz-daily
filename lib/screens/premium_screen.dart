import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/backend_service.dart';

/// Premium packages: user selects a package, sees payment instructions,
/// submits payment reference. Owner approves via admin panel.
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _package = '3mo'; // '3mo' or '6mo'
  final _refController = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;
  String? _error;
  String? _instructions;

  @override
  void initState() {
    super.initState();
    _loadInstructions();
  }

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  Future<void> _loadInstructions() async {
    final lang = context.read<AppState>().lang.name;
    final text = await BackendService.instance.getSetting(
      'payment_instructions_$lang',
    );
    if (mounted) {
      setState(() {
        _instructions = text ??
            'Send \$10 (3mo) or \$15 (6mo) via:\n(1) USDT (BEP20): 0x7021c100e43c8900bc5d6039583c390e87d3623c\n(2) Easypaisa IBAN: 4782780064795688\nThen submit your transaction ID below.';
      });
    }
  }

  Future<void> _submit() async {
    final ref = _refController.text.trim();
    if (ref.isEmpty) {
      setState(() => _error = 'Please enter your payment reference');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final ok = await BackendService.instance.applyForPremium(
      package: _package,
      paymentReference: ref,
    );
    if (mounted) {
      setState(() {
        _submitting = false;
        if (ok) {
          _submitted = true;
        } else {
          _error = 'Submission failed. Check your connection and try again.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(s.get('premiumTitle'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _submitted ? _buildSuccess(s, scheme) : _buildForm(s, scheme),
      ),
    );
  }

  Widget _buildForm(dynamic s, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Package selection
        Text(
          s.get('choosePackage'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _PackageCard(
          selected: _package == '3mo',
          title: s.get('package3mo'),
          price: '\$10',
          features: s.get('premiumFeatures'),
          onTap: () => setState(() => _package = '3mo'),
        ),
        const SizedBox(height: 12),
        _PackageCard(
          selected: _package == '6mo',
          title: s.get('package6mo'),
          price: '\$15',
          features: s.get('premiumFeatures'),
          badge: s.get('bestValue'),
          onTap: () => setState(() => _package = '6mo'),
        ),
        const SizedBox(height: 24),
        // Payment instructions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.payment_rounded, color: scheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    s.get('howToPay'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(_instructions ?? '...'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Payment reference input
        TextField(
          controller: _refController,
          decoration: InputDecoration(
            labelText: s.get('paymentRef'),
            hintText: s.get('paymentRefHint'),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.receipt_rounded),
            errorText: _error,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(s.get('submitApplication')),
        ),
        const SizedBox(height: 12),
        Text(
          s.get('premiumNote'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(dynamic s, ColorScheme scheme) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(
          Icons.check_circle_rounded,
          size: 80,
          color: Colors.green.shade600,
        ),
        const SizedBox(height: 16),
        Text(
          s.get('applicationSubmitted'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          s.get('applicationPending'),
          textAlign: TextAlign.center,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.get('backBtn')),
        ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final bool selected;
  final String title;
  final String price;
  final String features;
  final String? badge;
  final VoidCallback onTap;

  const _PackageCard({
    required this.selected,
    required this.title,
    required this.price,
    required this.features,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? scheme.primary : scheme.outline,
            width: selected ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: selected
              ? scheme.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: '',
              groupValue: selected ? '' : null,
              onChanged: (_) => onTap(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    features,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
