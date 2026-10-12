import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../game/puzzle.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../services/points_service.dart';
import '../services/stats_service.dart';
import '../state/game_controller.dart';
import 'archive_screen.dart';
import 'game_screen.dart';
import 'how_to_play_screen.dart';
import 'settings_screen.dart';
import 'splash_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;
    final stats = StatsService.instance.get(appState.lang);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: s.get('stats'),
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            ),
          ),
          IconButton(
            tooltip: s.get('settings'),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: 92),
                const SizedBox(height: 14),
                Text(
                  AppConfig.appName(appState.lang),
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w800),
                ),
                Text(s.get('tagline'),
                    style: TextStyle(
                        fontSize: 15, color: scheme.onSurfaceVariant)),
                const SizedBox(height: 18),
                // Language toggle: EN | اردو | عربية | ES
                SegmentedButton<AppLang>(
                  segments: const [
                    ButtonSegment(
                        value: AppLang.en, label: Text('EN')),
                    ButtonSegment(
                        value: AppLang.ur, label: Text('اردو')),
                    ButtonSegment(
                        value: AppLang.ar, label: Text('عربية')),
                    ButtonSegment(
                        value: AppLang.es, label: Text('ES')),
                  ],
                  selected: {appState.lang},
                  onSelectionChanged: (sel) =>
                      appState.setLang(sel.first),
                ),
                const SizedBox(height: 14),
                // Streak flame
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    '🔥 ${stats.currentStreak} ${s.get('streak')}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 22),
                // Points balance (tappable → wallet history)
                _BalancePill(s: s),
                const SizedBox(height: 16),
                // Five daily puzzles
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    s.get('dailyPuzzles'),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 0; i < Puzzle.puzzlesPerDay; i++)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              right:
                                  i == Puzzle.puzzlesPerDay - 1 ? 0 : 8),
                          child: _PuzzleSlotButton(slot: i),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Practice
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.casino_outlined),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        children: [
                          Text(s.get('practice'),
                              style: const TextStyle(fontSize: 17)),
                          Text(s.get('practiceSub'),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const GameScreen.practice()),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.history_rounded),
                        label: Text(s.get('archive')),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const ArchiveScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.help_outline_rounded),
                        label: Text(s.get('howToPlay')),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  const HowToPlayScreen(firstLaunch: false)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${s.get('nextIn')}: ${Puzzle.countdownText(Puzzle.timeUntilNext())}',
                  style: TextStyle(
                      fontSize: 13, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One of the five daily puzzle slots. Shows a green check once done.
class _PuzzleSlotButton extends StatelessWidget {
  const _PuzzleSlotButton({required this.slot});
  final int slot;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final done = GameController.isSlotDoneToday(appState.lang, slot);
    final scheme = Theme.of(context).colorScheme;
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor:
            done ? const Color(0xFF4C9A52) : scheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => GameScreen.daily(slot: slot)),
      ),
      child: Text(
        done ? '✓' : '${slot + 1}',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// Tappable balance pill showing the points wallet total.
class _BalancePill extends StatelessWidget {
  const _BalancePill({required this.s});
  final S s;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _showWallet(context, s),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          '💰 ${PointsService.instance.balanceText} ${s.get('balance')}',
          style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

void _showWallet(BuildContext context, S s) {
  final points = PointsService.instance;
  final hist = points.history;
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('💰 ${points.balanceText} ${s.get('balance')}'),
      content: SizedBox(
        width: double.maxFinite,
        child: hist.isEmpty
            ? Text(s.get('noHistory'))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: hist.length,
                itemBuilder: (_, i) {
                  final e = hist[i];
                  final cents = (e['c'] as num?)?.toInt() ?? 0;
                  return ListTile(
                    dense: true,
                    leading: const Text('🎉',
                        style: TextStyle(fontSize: 20)),
                    title: Text(
                        '+\$${(cents / 100).toStringAsFixed(2)}'),
                    subtitle: Text(_historyLabel(e)),
                  );
                },
              ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(s.get('ok')),
        ),
      ],
    ),
  );
}

/// Turns a stored puzzle key (game_<lang>_daily_YYYY-MM-DD_<slot>)
/// into a friendly "Puzzle 3 • 2026-10-12" label.
String _historyLabel(Map<String, dynamic> e) {
  final k = (e['k'] as String?) ?? '';
  final m = RegExp(r'_daily_(\d{4}-\d{2}-\d{2})_(\d+)$').firstMatch(k);
  if (m != null) {
    final slot = (int.tryParse(m.group(2)!) ?? 0) + 1;
    return 'Puzzle $slot • ${m.group(1)}';
  }
  return (e['d'] as String?) ?? '';
}
