import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/backend_service.dart';

/// Withdrawal screen: user enters payout details and requests withdrawal.
/// Minimum $5.00. Owner pays manually via admin panel.
class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  String _method = 'easypaisa';
  final _detailsController = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;
  String? _error;
  double? _balance;
  double _minWithdrawal = 5.00;

  final _methods = [
    ('easypaisa', 'Easypaisa'),
    ('jazzcash', 'JazzCash'),
    ('bank', 'Bank Transfer'),
    ('usdt', 'USDT'),
    ('paypal', 'PayPal'),
  ];

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _loadBalance() async {
    final bal = await BackendService.instance.getServerBalance();
    final minStr =
        await BackendService.instance.getSetting('min_withdrawal');
    if (mounted) {
      setState(() {
        _balance = bal ?? 0.0;
        _minWithdrawal = double.tryParse(minStr ?? '5.00') ?? 5.00;
      });
    }
  }

  Future<void> _submit() async {
    final details = _detailsController.text.trim();
    if (details.isEmpty) {
      setState(() => _error = 'Please enter your account details');
      return;
    }
    if ((_balance ?? 0) < _minWithdrawal) {
      setState(() => _error = 'Minimum withdrawal is \$$_minWithdrawal');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final ok = await BackendService.instance.requestWithdrawal(
      amount: _balance!,
      method: _method,
      accountDetails: details,
    );
    if (mounted) {
      setState(() {
        _submitting = false;
        if (ok) {
          _submitted = true;
        } else {
          _error = 'Request failed. Check connection and try again.';
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
      appBar: AppBar(title: Text(s.get('withdrawTitle'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _submitted ? _buildSuccess(s, scheme) : _buildForm(s, scheme),
      ),
    );
  }

  Widget _buildForm(dynamic s, ColorScheme scheme) {
    final canWithdraw = (_balance ?? 0) >= _minWithdrawal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Balance card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                s.get('yourBalance'),
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${(_balance ?? 0).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${s.get('minWithdrawal')}: \$$_minWithdrawal',
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Method selection
        Text(
          s.get('payoutMethod'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _methods.map((m) {
            final selected = _method == m.$1;
            return ChoiceChip(
              label: Text(m.$2),
              selected: selected,
              onSelected: (_) => setState(() => _method = m.$1),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Account details
        TextField(
          controller: _detailsController,
          decoration: InputDecoration(
            labelText: s.get('accountDetails'),
            hintText: s.get('accountDetailsHint'),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
            errorText: _error,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: (!canWithdraw || _submitting) ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(s.get('requestWithdrawal')),
        ),
        if (!canWithdraw) ...[
          const SizedBox(height: 12),
          Text(
            s.get('withdrawLocked'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
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
          s.get('withdrawSubmitted'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          s.get('withdrawPending'),
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
