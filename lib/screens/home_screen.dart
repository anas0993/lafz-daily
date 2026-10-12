import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../game/puzzle.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../services/stats_service.dart';
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
                // Play daily
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(s.get('playDaily'),
                          style: const TextStyle(fontSize: 20)),
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const GameScreen.daily()),
                    ),
                  ),
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
