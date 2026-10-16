import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/lang_utils.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../services/challenge_service.dart';
import '../services/share_service.dart';

/// 1v1 friend challenge screen (fully local).
///
/// Two sections:
///  1. Create — type a 5-letter word, get a shareable code, copy it to the
///     friend.
///  2. Join — paste a friend's code to play their word.
///
/// This screen is decoupled from the game itself: it takes an
/// [onPlayWord] callback. The parent wires it like:
///
///   ChallengeScreen(
///     onPlayWord: (word) => Navigator.of(context).push(
///       MaterialPageRoute(builder: (_) => GameScreen.challenge(word)),
///     ),
///   )
///
/// That requires a `GameScreen.challenge(String word)` constructor (or an
/// equivalent route) that launches a game with the custom answer.
class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key, required this.onPlayWord});

  /// Called with the decoded 5-letter word when the user taps "Play" on a
  /// joined challenge. The parent launches the game with this word.
  final void Function(String word) onPlayWord;

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final _wordController = TextEditingController();
  final _codeController = TextEditingController();

  String? _generatedCode;
  String? _createError;
  String? _joinError;

  @override
  void dispose() {
    _wordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _onCreate(S s) async {
    final word = _wordController.text;
    if (!ChallengeService.isValidWord(word)) {
      setState(() {
        _createError = s.get('wordMustBe5');
        _generatedCode = null;
      });
      return;
    }
    try {
      final code = ChallengeService.instance.createChallenge(word);
      await ChallengeService.instance.saveOutgoing(code, word);
      setState(() {
        _generatedCode = code;
        _createError = null;
      });
    } catch (_) {
      // Defensive: isValidWord passed, so this should not happen.
      setState(() {
        _createError = s.get('wordMustBe5');
        _generatedCode = null;
      });
    }
  }

  Future<void> _onCopyCode(BuildContext context, S s, String code) async {
    await ShareService.share(code);
    if (!context.mounted) return;
    _showSnack(context, s.get('codeCopied'));
  }

  Future<void> _onJoin(S s) async {
    final code = _codeController.text.trim();
    final word = ChallengeService.instance.decodeChallenge(code);
    if (word == null) {
      setState(() => _joinError = s.get('invalidCode'));
      return;
    }
    await ChallengeService.instance.saveIncoming(code, word);
    setState(() => _joinError = null);
    widget.onPlayWord(word);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;
    final rtl = appState.lang.isRtl;
    final scheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.get('challengeTitle')),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // -------------------------------------------------- create --
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      s.get('createChallenge'),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _wordController,
                      maxLength: 5,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: s.get('yourWord'),
                        border: const OutlineInputBorder(),
                        counterText: '',
                        errorText: _createError,
                      ),
                      onChanged: (_) {
                        if (_createError != null) {
                          setState(() => _createError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _onCreate(s),
                      icon: const Icon(Icons.sports_kabaddi_rounded),
                      label: Text(s.get('createCode')),
                    ),
                    if (_generatedCode != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        s.get('yourCode'),
                        style: Theme.of(context).textTheme.labelLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _generatedCode!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _onCopyCode(context, s, _generatedCode!),
                        icon: const Icon(Icons.copy_rounded),
                        label: Text(s.get('copyCode')),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ---------------------------------------------------- join --
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      s.get('joinChallenge'),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _codeController,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: s.get('enterCode'),
                        border: const OutlineInputBorder(),
                        errorText: _joinError,
                      ),
                      onChanged: (_) {
                        if (_joinError != null) {
                          setState(() => _joinError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: () => _onJoin(s),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(s.get('playChallenge')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
