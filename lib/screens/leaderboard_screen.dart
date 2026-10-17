import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/strings.dart';
import '../main.dart';
import '../services/stats_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/wood_theme.dart';

/// Local leaderboard screen (Workstream 5: Social).
///
/// Three sections: Most Wins (total), Best Streak, Scramble Wins.
/// Stats are aggregated across all four app languages from [StatsService].
/// Scramble wins are read from SharedPreferences key 'wd_scramble_wins'
/// (written by the future scramble game; defaults to 0 when absent).
///
/// Parent wiring: push via
///   Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaderboardScreen()));
///
/// String keys used (parent merges into strings.dart):
///   'leaderboard', 'mostWins', 'bestStreak', 'scrambleWins',
///   'yourScore', 'friendSlotsSoon', 'shareCodeSoon', 'you'
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  int _scrambleWins = 0;
  int _totalWins = 0;
  int _bestStreak = 0;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    // Aggregate word-puzzle stats across all four languages.
    int wins = 0;
    int streak = 0;
    for (final lang in AppLang.values) {
      final st = StatsService.instance.get(lang);
      wins += st.wins;
      if (st.maxStreak > streak) streak = st.maxStreak;
    }
    final prefs = await SharedPreferences.getInstance();
    final scramble = prefs.getInt('wd_scramble_wins') ?? 0;
    if (mounted) {
      setState(() {
        _totalWins = wins;
        _bestStreak = streak;
        _scrambleWins = scramble;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;

    final sections = [
      _Section(titleKey: 'mostWins', icon: Icons.emoji_events, value: _totalWins),
      _Section(titleKey: 'bestStreak', icon: Icons.local_fire_department, value: _bestStreak),
      _Section(titleKey: 'scrambleWins', icon: Icons.shuffle, value: _scrambleWins),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(s.get('leaderboard')),
        backgroundColor: WoodTheme.emerald,
        foregroundColor: WoodTheme.cream,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: WoodTheme.gold,
          labelColor: WoodTheme.cream,
          unselectedLabelColor: WoodTheme.cream.withValues(alpha: 0.7),
          tabs: sections
              .map((sec) => Tab(
                    icon: Icon(sec.icon, size: 20),
                    text: s.get(sec.titleKey),
                  ))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: sections
            .map((sec) => AnimatedBackground(
                  child: _buildSection(context, s, sec),
                ))
            .toList(),
      ),
    );
  }

  /// One leaderboard section: top-3 trophy-flavoured rows. Solo for now —
  /// rank 1 is the player; ranks 2–3 hold slots for friend comparisons.
  Widget _buildSection(BuildContext context, S s, _Section sec) {
    const medals = ['🥇', '🥈', '🥉'];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        Center(
          child: Column(
            children: [
              Text(medals[0], style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
              Text(
                '${sec.value}',
                style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800),
              ),
              Text(s.get('yourScore'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(3, (i) {
          final isYou = i == 0;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: Text(medals[i], style: const TextStyle(fontSize: 28)),
              title: Text(
                isYou ? s.get('you') : '${i + 1}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: Text(
                isYou ? '${sec.value}' : s.get('friendSlotsSoon'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isYou
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.45),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        // Friend comparison note.
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  s.get('shareCodeSoon'),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section {
  const _Section({required this.titleKey, required this.icon, required this.value});
  final String titleKey;
  final IconData icon;
  final int value;
}
