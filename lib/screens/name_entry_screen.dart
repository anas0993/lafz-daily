import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/backend_service.dart';

/// First-launch name entry: player enters their name so the
/// backend can identify them for rewards, withdrawals, and premium.
class NameEntryScreen extends StatefulWidget {
  const NameEntryScreen({super.key});

  @override
  State<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends State<NameEntryScreen> {
  final _controller = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter your name');
      return;
    }
    if (name.length < 2) {
      setState(() => _error = 'Name is too short');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    await BackendService.instance.setPlayerName(name);
    // Try to register with backend (fails silently if offline)
    await BackendService.instance.init();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.person_add_rounded,
                size: 72,
                color: scheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                s.get('enterNameTitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.get('enterNameDesc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
                decoration: InputDecoration(
                  labelText: s.get('yourName'),
                  hintText: s.get('nameHint'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person_rounded),
                  errorText: _error,
                ),
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(s.get('continueBtn')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
