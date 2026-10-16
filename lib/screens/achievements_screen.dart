import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/achievements_service.dart';

/// Shows every achievement with its locked/unlocked state.
///
/// PARENT WIRING (route):
///   Navigator.of(context).push(
///     MaterialPageRoute(builder: (_) => const AchievementsScreen()),
///   );
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;
    final scheme = Theme.of(context).colorScheme;
    final items = AchievementsService.instance.all();
    final unlocked = items.where((a) => a.unlocked).length;

    return Scaffold(
      appBar: AppBar(title: Text(s.get('achievements'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Progress header.
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 30)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$unlocked / ${items.length}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: items.isEmpty
                                ? 0
                                : unlocked / items.length,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((a) => _AchievementTile(
                state: a,
                scheme: scheme,
                title: s.get(a.def.titleKey),
                desc: s.get(a.def.descKey),
                coinsLabel: s.get('coinsLabel'),
                lockedLabel: s.get('achLocked'),
                unlockedLabel: s.get('achUnlocked'),
              )),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.state,
    required this.scheme,
    required this.title,
    required this.desc,
    required this.coinsLabel,
    required this.lockedLabel,
    required this.unlockedLabel,
  });

  final AchievementState state;
  final ColorScheme scheme;
  final String title;
  final String desc;
  final String coinsLabel;
  final String lockedLabel;
  final String unlockedLabel;

  @override
  Widget build(BuildContext context) {
    final unlocked = state.unlocked;
    final badgeColor = unlocked
        ? scheme.primaryContainer
        : scheme.surfaceContainerHighest;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: badgeColor,
              child: Text(
                unlocked ? '🏆' : '🔒',
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: unlocked
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                      )),
                  const SizedBox(height: 2),
                  Text(desc,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      )),
                  const SizedBox(height: 4),
                  Text('+${state.def.coins} $coinsLabel',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: scheme.tertiary,
                      )),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: unlocked
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                unlocked ? unlockedLabel : lockedLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: unlocked
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
