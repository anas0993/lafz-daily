import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/share_service.dart';
import '../services/stats_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/wood_theme.dart';
import 'streak_calendar_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;
    final stats = StatsService.instance.get(appState.lang);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.get('stats')),
        backgroundColor: WoodTheme.emerald,
        foregroundColor: WoodTheme.cream,
      ),
      body: AnimatedBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _Tile(value: '${stats.played}', label: s.get('played')),
                _Tile(
                    value: '${stats.winPct.toStringAsFixed(0)}%',
                    label: s.get('winPct')),
                _Tile(
                    value: '${stats.currentStreak}',
                    label: s.get('curStreak')),
                _Tile(
                    value: '${stats.maxStreak}', label: s.get('maxStreak')),
              ],
            ),
            const SizedBox(height: 24),
            Text(s.get('distribution'),
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...List.generate(6, (i) {
              final count = stats.distribution[i];
              final max = stats.distribution
                  .fold<int>(1, (a, b) => a > b ? a : b);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                        width: 20,
                        child: Text('${i + 1}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600))),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: 22,
                          width: 40 +
                              (count / max) *
                                  (MediaQuery.of(context).size.width - 160),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: count > 0
                                ? scheme.primary
                                : scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('$count',
                              style: TextStyle(
                                  color: count > 0
                                      ? scheme.onPrimary
                                      : scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_month_rounded),
              // WS4 (v4.1): navigation-only addition to the streak calendar.
              label: Text(s.get('streakCalendar')),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const StreakCalendarScreen()),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.share_rounded),
              label: Text(s.get('share')),
              onPressed: () {
                final text =
                    '${s.puzzleTag(0).replaceAll(' #0', '')}\n${s.get('played')}: ${stats.played} • ${s.get('winPct')}: ${stats.winPct.toStringAsFixed(0)}% • 🔥${stats.currentStreak}';
                ShareService.share(text);
              },
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
