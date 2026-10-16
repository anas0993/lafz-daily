import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../game/puzzle.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../services/stats_service.dart';
import '../state/game_controller.dart';
import 'archive_screen.dart';
import 'game_screen.dart';
import 'how_to_play_screen.dart';
import 'settings_screen.dart';
import 'splash_screen.dart';
import 'premium_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;
    // Watch reactive services so UI updates when stats change
    // (EARNING DISABLED in interim build: PointsService not watched)
    context.watch<StatsService>();
    final stats = StatsService.instance.get(appState.lang);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gaming-style gradient header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1B5E20), const Color(0xFF0D3B1E)]
                        : [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppLogo(size: 72),
                      const SizedBox(height: 8),
                      Text(
                        AppConfig.appName(appState.lang),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        s.get('tagline'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                tooltip: s.get('stats'),
                icon: const Icon(Icons.bar_chart_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                ),
              ),
              IconButton(
                tooltip: s.get('settings'),
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Stats cards row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: '🔥',
                          value: '${stats.currentStreak}',
                          label: s.get('streak'),
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // EARNING DISABLED (interim build): wins card replaces
                      // the old balance card. Cash rewards return after the
                      // organization-account transfer.
                      Expanded(
                        child: _StatCard(
                          icon: '🏆',
                          value: '${stats.wins}',
                          label: s.get('wins'),
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: '🎮',
                          value: '${stats.played}',
                          label: s.get('played'),
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Language selector
                  _LanguageSelector(s: s, appState: appState),

                  const SizedBox(height: 20),

                  // Daily puzzles section
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 20, color: scheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        s.get('dailyPuzzles'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${s.get('nextIn')}: ${Puzzle.countdownText(Puzzle.timeUntilNext())}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Puzzle slots - gaming cards
                  Row(
                    children: [
                      for (var i = 0; i < Puzzle.puzzlesPerDay; i++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: i == Puzzle.puzzlesPerDay - 1 ? 0 : 10),
                            child: _PuzzleSlotCard(slot: i),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Premium banner
                  _PremiumBanner(s: s),

                  const SizedBox(height: 16),

                  // Action grid 2x2
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.2,
                    children: [
                      _ActionCard(
                        icon: Icons.casino_outlined,
                        title: s.get('practice'),
                        subtitle: s.get('practiceSub'),
                        color: Colors.blue,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const GameScreen.practice()),
                        ),
                      ),
                      _ActionCard(
                        icon: Icons.history_rounded,
                        title: s.get('archive'),
                        subtitle: '',
                        color: Colors.purple,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const ArchiveScreen()),
                        ),
                      ),
                      _ActionCard(
                        icon: Icons.help_outline_rounded,
                        title: s.get('howToPlay'),
                        subtitle: '',
                        color: Colors.teal,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  const HowToPlayScreen(firstLaunch: false)),
                        ),
                      ),
                      _ActionCard(
                        icon: Icons.bar_chart_rounded,
                        title: s.get('stats'),
                        subtitle: '',
                        color: Colors.orange,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const StatsScreen()),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat card with icon, value, label
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final String icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Language selector - English main, others in bottom sheet
class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.s, required this.appState});

  final S s;
  final AppState appState;

  String _langLabel(AppLang lang) {
    switch (lang) {
      case AppLang.en:
        return 'ENG';
      case AppLang.ur:
        return 'اردو';
      case AppLang.ar:
        return 'عربية';
      case AppLang.es:
        return 'ESP';
    }
  }

  String _langName(AppLang lang) {
    switch (lang) {
      case AppLang.en:
        return 'English';
      case AppLang.ur:
        return 'اردو';
      case AppLang.ar:
        return 'العربية';
      case AppLang.es:
        return 'Español';
    }
  }

  void _showLanguageSheet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            for (final lang in AppLang.values)
              ListTile(
                leading: Text(
                  _langLabel(lang),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                title: Text(_langName(lang)),
                trailing: appState.lang == lang
                    ? Icon(Icons.check_circle,
                        color: scheme.primary)
                    : null,
                onTap: () {
                  appState.setLang(lang);
                  Navigator.of(ctx).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _showLanguageSheet(context),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: scheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language_rounded, size: 18),
              const SizedBox(width: 8),
              Text(
                _langLabel(appState.lang),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: scheme.onPrimaryContainer,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: scheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Puzzle slot as gaming card
class _PuzzleSlotCard extends StatelessWidget {
  const _PuzzleSlotCard({required this.slot});

  final int slot;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final done = GameController.isSlotDoneToday(appState.lang, slot);
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => GameScreen.daily(slot: slot)),
      ),
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          gradient: done
              ? const LinearGradient(
                  colors: [Color(0xFF4C9A52), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    scheme.primary,
                    scheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (done ? Colors.green : scheme.primary).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            done ? '✓' : '${slot + 1}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium banner - gold gradient
class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner({required this.s});

  final S s;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              s.get('premiumTitle'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

/// Action card for grid
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
