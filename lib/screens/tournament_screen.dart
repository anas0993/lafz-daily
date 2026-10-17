import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/rewards_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/wood_theme.dart';

/// Weekly tournament overview (local-only ranking).
///
/// Shows this week's win count, a flavor rank (Bronze <3, Silver <7,
/// Gold <12, Diamond 12+), the best week ever, and a note that global sync
/// is coming. Weeks reset on Monday (see RewardsService.weekKey).
///
/// PARENT WIRING (route):
///   Navigator.of(context).push(
///     MaterialPageRoute(builder: (_) => const TournamentScreen()),
///   );
class TournamentScreen extends StatelessWidget {
  const TournamentScreen({super.key});

  static const _rankKeys = ['rankBronze', 'rankSilver', 'rankGold', 'rankDiamond'];
  static const _rankEmojis = ['🥉', '🥈', '🥇', '💎'];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;
    final scheme = Theme.of(context).colorScheme;

    final rewards = RewardsService.instance;
    final weekWins = rewards.currentWeekWins();
    final bestWeek = rewards.bestWeekEver();
    final tier = RewardsService.rankTier(weekWins);
    final toNext = RewardsService.winsToNextTier(weekWins);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.get('tournament')),
        backgroundColor: WoodTheme.emerald,
        foregroundColor: WoodTheme.cream,
      ),
      body: AnimatedBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Rank card.
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    Text(_rankEmojis[tier], style: const TextStyle(fontSize: 56)),
                    const SizedBox(height: 8),
                    Text(s.get('yourRank'),
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        )),
                    Text(s.get(_rankKeys[tier]),
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Text('$weekWins',
                        style: const TextStyle(
                            fontSize: 44, fontWeight: FontWeight.w800)),
                    Text(s.get('thisWeekWins'),
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onSurfaceVariant,
                        )),
                    const SizedBox(height: 8),
                    Text(
                      toNext > 0
                          ? s.get('playMoreToRankUp')
                          : '💎',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: WoodTheme.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Stats row.
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    value: '$bestWeek',
                    label: s.get('bestWeek'),
                    scheme: scheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    value: s.get('weeklyResets'),
                    label: s.get('tournament'),
                    scheme: scheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Global sync note.
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌍', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(s.get('globalSyncSoon'),
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        )),
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.scheme,
  });

  final String value;
  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            Text(value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                )),
          ],
        ),
      ),
    );
  }
}
