import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../services/storage_service.dart';
import 'wood_theme.dart';

/// First-run coach-mark overlay: 3 quick steps, shown once, then never
/// again. Reads/writes the shared_preferences flag 'tutorial_seen' itself.
///
/// Wiring (game_screen.dart — owned by another workstream):
///   1. Add:  import '../widgets/tutorial_overlay.dart';
///   2. In _GameViewState.initState, add:
///        WidgetsBinding.instance.addPostFrameCallback((_) {
///          if (mounted) TutorialOverlay.maybeShow(context, appState.s);
///        });
///      (appState.s gives the S instance; appState is reachable via
///      context.read<AppState>() / the existing context.watch<AppState>()).
/// No other wiring needed — the flag check, dialog, and persistence are
/// all handled here.
class TutorialOverlay extends StatefulWidget {
  const TutorialOverlay({super.key, required this.s});

  final S s;

  /// SharedPreferences flag: 'tutorial_seen' != true ⇒ show the tutorial.
  static const flagKey = 'tutorial_seen';

  static Future<void> maybeShow(BuildContext context, S s) async {
    bool seen = false;
    try {
      seen = StorageService.instance.getBool(flagKey) == true;
    } catch (_) {}
    if (seen || !context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TutorialOverlay(s: s),
    );
    // Set on completion AND on Skip/back — never nag twice.
    try {
      await StorageService.instance.setBool(flagKey, true);
    } catch (_) {}
  }

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  final _pages = PageController();
  int _page = 0;

  static const _steps = [
    ('⌨️', 'tutorialStep1'),
    ('⏎', 'tutorialStep2'),
    ('🟩', 'tutorialStep3'),
  ];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _steps.length - 1) {
      _pages.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.of(context).pop(); // completion — flag set by maybeShow
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return Dialog(
      backgroundColor: WoodTheme.cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: WoodTheme.gold, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  s.get('tutorialSkip'),
                  style: const TextStyle(
                    color: WoodTheme.woodLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Text(
              s.get('howToPlay'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: WoodTheme.bark,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 170,
              child: PageView.builder(
                controller: _pages,
                itemCount: _steps.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final (icon, key) = _steps[i];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 52)),
                      const SizedBox(height: 16),
                      Text(
                        s.get(key),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: WoodTheme.bark,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Dots.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _steps.length; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _page
                          ? WoodTheme.emerald
                          : WoodTheme.woodLight.withValues(alpha: 0.35),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WoodTheme.emerald,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _page < _steps.length - 1
                      ? s.get('tutorialNext')
                      : s.get('tutorialGotIt'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
