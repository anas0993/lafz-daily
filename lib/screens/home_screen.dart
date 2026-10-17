import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../game/puzzle.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../services/booster_service.dart';
import '../services/coins_service.dart';
import '../services/rewards_service.dart';
import '../services/stats_service.dart';
import '../services/storage_service.dart';
import '../state/game_controller.dart';
import '../widgets/ad_slot.dart';
import '../widgets/scene_background.dart';
import '../widgets/wood_theme.dart';
import 'achievements_screen.dart';
import 'archive_screen.dart';
import 'challenge_screen.dart';
import 'game_screen.dart';
import 'how_to_play_screen.dart';
import 'leaderboard_screen.dart';
import 'scramble_screen.dart';
import 'settings_screen.dart';
import 'splash_screen.dart';
import 'premium_screen.dart';
import 'stats_screen.dart';
import 'team_screen.dart';
import 'tournament_screen.dart';
import 'word_fever_screen.dart';

/// v4.2 home excellence pass (reference: "Wordle!" by Lion Studios —
/// richness, not colors): illustrated scene background, rich floating top
/// status bar (coins + hints pills, settings), hero logo over the art,
/// chunky mode buttons with badges (CLASSIC + stats, DAILY PUZZLE + date),
/// WORD FEVER / SCRAMBLE duo, wide 1v1 CHALLENGE banner, wooden bottom
/// shortcut bar. Everything in the emerald/gold wooden-luxury theme.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// First daily slot not finished today (falls back to slot 0 when all
  /// five are done).
  int _nextOpenSlot(AppLang lang) {
    for (var i = 0; i < Puzzle.puzzlesPerDay; i++) {
      if (!GameController.isSlotDoneToday(lang, i)) return i;
    }
    return 0;
  }

  /// v4.2: persisted Word Fever best score for the duo badge.
  String _wordFeverBadge(S s) {
    final best =
        StorageService.instance.getInt('word_fever_best') ?? 0;
    return best > 0 ? '⭐ $best' : s.get('newBadge');
  }

  /// v4.2: persisted Scramble wins for the duo badge.
  int _scrambleWins() =>
      StorageService.instance.getInt('scramble_wins_total') ?? 0;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;
    // Watch reactive services so UI updates when stats change
    // (EARNING DISABLED in interim build: PointsService not watched)
    context.watch<StatsService>();
    final stats = StatsService.instance.get(appState.lang);

    return Scaffold(
      extendBodyBehindAppBar: true,
      // v4.2: illustrated scene background behind everything.
      body: SceneBackground(
        asset: 'assets/images/bg_home.png',
        scrimOpacity: 0.5,
        child: CustomScrollView(
          slivers: [
            // v4.2: rich floating top status bar over the scene art.
            SliverAppBar(
              pinned: true,
              toolbarHeight: 64,
              automaticallyImplyLeading: false,
              backgroundColor:
                  WoodTheme.emeraldDeep.withValues(alpha: 0.78),
              titleSpacing: 12,
              title: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _WoodCoinChip(),
                  SizedBox(width: 8),
                  _HintsPill(),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: s.get('settings'),
                  icon: const Icon(Icons.settings_rounded,
                      color: WoodTheme.cream),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),

            // v4.2: hero — logo + name + tagline floating over the art.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 8),
                child: Column(
                  children: [
                    const AppLogo(size: 88),
                    const SizedBox(height: 10),
                    Text(
                      AppConfig.appName(appState.lang),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: WoodTheme.cream,
                        letterSpacing: 1.4,
                        shadows: [
                          Shadow(
                            color:
                                Colors.black.withValues(alpha: 0.55),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      s.get('tagline'),
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            WoodTheme.cream.withValues(alpha: 0.92),
                        shadows: [
                          Shadow(
                            color:
                                Colors.black.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // v4: daily login reward check (zero-size widget).
                    const _DailyRewardCheck(),

                    // Stats cards row (wood restyle).
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: '🔥',
                            value: '${stats.currentStreak}',
                            label: s.get('streak'),
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
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: '🎮',
                            value: '${stats.played}',
                            label: s.get('played'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Language selector (wood restyle).
                    _LanguageSelector(s: s, appState: appState),

                    const SizedBox(height: 20),

                    // v4.2: big chunky rounded mode buttons with badges
                    // (reference layout richness, wooden theme).
                    // CLASSIC carries a stats shortcut icon + streak badge.
                    _ChunkyModeButton(
                      emoji: '📝',
                      title: s.get('classic'),
                      subtitle: s.get('classicSub'),
                      badge: '🔥 ${stats.currentStreak}',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GameScreen.daily(
                              slot: _nextOpenSlot(appState.lang)),
                        ),
                      ),
                      trailing: IconButton(
                        tooltip: s.get('stats'),
                        icon: const Icon(Icons.bar_chart_rounded,
                            color: WoodTheme.gold),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const StatsScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // DAILY PUZZLE banner with today's date badge.
                    _ChunkyModeButton(
                      emoji: '📅',
                      title: s.get('dailyPuzzle'),
                      subtitle: s.get('dailyPuzzleSub'),
                      badge: '🗓️ ${DateTime.now().day}',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GameScreen.daily(
                              slot: _nextOpenSlot(appState.lang)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // WORD FEVER / SCRAMBLE side-by-side duo.
                    Row(
                      children: [
                        Expanded(
                          child: _DuoModeButton(
                            emoji: '⚡',
                            title: s.get('wordFever'),
                            badge: _wordFeverBadge(s),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const WordFeverScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DuoModeButton(
                            emoji: '🔀',
                            title: s.get('scramble'),
                            badge:
                                '🏆 ${_scrambleWins()}',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ScrambleScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Wide 1v1 CHALLENGE banner (friend battles).
                    _ChallengeBanner(
                      s: s,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChallengeScreen(
                            onPlayWord: (word) =>
                                Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      GameScreen.challenge(word)),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Daily puzzles section: chunky DAILY PUZZLE header row
                    // + the five slot cards.
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: WoodTheme.emerald,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: WoodTheme.gold, width: 1.5),
                          ),
                          child: const Icon(
                              Icons.calendar_today_rounded,
                              size: 18,
                              color: WoodTheme.cream),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          s.get('dailyPuzzle'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: WoodTheme.woodDark,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: WoodTheme.woodDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: WoodTheme.gold, width: 1),
                          ),
                          child: Text(
                            '${s.get('nextIn')}: ${Puzzle.countdownText(Puzzle.timeUntilNext())}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: WoodTheme.cream,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        for (var i = 0; i < Puzzle.puzzlesPerDay; i++)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right:
                                      i == Puzzle.puzzlesPerDay - 1 ? 0 : 10),
                              child: _PuzzleSlotCard(slot: i),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Premium banner
                    _PremiumBanner(s: s),

                    const SizedBox(height: 16),

                    // More modes & features (wood restyle).
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.2,
                      children: [
                        _ActionCard(
                          icon: Icons.history_rounded,
                          title: s.get('archive'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const ArchiveScreen()),
                          ),
                        ),
                        _ActionCard(
                          icon: Icons.help_outline_rounded,
                          title: s.get('howToPlay'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    const HowToPlayScreen(firstLaunch: false)),
                          ),
                        ),
                        _ActionCard(
                          icon: Icons.bar_chart_rounded,
                          title: s.get('stats'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const StatsScreen()),
                          ),
                        ),
                        // v4: social / retention entries.
                        _ActionCard(
                          icon: Icons.sports_esports_outlined,
                          title: s.get('challengeTitle'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChallengeScreen(
                                onPlayWord: (word) =>
                                    Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          GameScreen.challenge(word)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _ActionCard(
                          icon: Icons.groups_outlined,
                          title: s.get('team'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const TeamScreen()),
                          ),
                        ),
                        _ActionCard(
                          icon: Icons.leaderboard_outlined,
                          title: s.get('leaderboard'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const LeaderboardScreen()),
                          ),
                        ),
                        _ActionCard(
                          icon: Icons.emoji_events_outlined,
                          title: s.get('achievements'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const AchievementsScreen()),
                          ),
                        ),
                        _ActionCard(
                          icon: Icons.military_tech_outlined,
                          title: s.get('tournament'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const TournamentScreen()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    // v4: ad placement slot (banner).
                    const AdSlot(slotName: 'home_bottom'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // v4.2: wooden bottom shortcut bar (reference layout richness).
      bottomNavigationBar: _BottomShortcutBar(s: s),
    );
  }
}

/// v4.1: big chunky rounded mode button (reference: "Wordle!" by Lion
/// Studios). Wood gradient body, gold border, big emoji icon, title +
/// subtitle, best-score badge pill, optional trailing widget, chevron.
class _ChunkyModeButton extends StatelessWidget {
  const _ChunkyModeButton({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
    this.trailing,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              WoodTheme.lighten(WoodTheme.wood, 0.10),
              WoodTheme.wood,
              WoodTheme.woodDark,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: WoodTheme.gold, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: WoodTheme.gold.withValues(alpha: 0.18),
                border:
                    Border.all(color: WoodTheme.goldSoft, width: 1.5),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 30)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: WoodTheme.cream,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: WoodTheme.cream.withValues(alpha: 0.78),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: WoodTheme.cream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: WoodTheme.goldSoft, width: 1),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: WoodTheme.woodDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            const Icon(Icons.chevron_right_rounded,
                color: WoodTheme.goldSoft, size: 30),
          ],
        ),
      ),
    );
  }
}

/// Stat card with icon, value, label — wood restyle.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: WoodTheme.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WoodTheme.woodLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: WoodTheme.emerald,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: WoodTheme.wood,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Language selector - English main, others in bottom sheet (wood restyle).
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
    showModalBottomSheet(
      context: context,
      backgroundColor: WoodTheme.cream,
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
                color: WoodTheme.woodLight.withValues(alpha: 0.4),
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
                    color: WoodTheme.woodDark,
                  ),
                ),
                title: Text(_langName(lang),
                    style:
                        const TextStyle(color: WoodTheme.woodDark)),
                trailing: appState.lang == lang
                    ? const Icon(Icons.check_circle,
                        color: WoodTheme.emerald)
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
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _showLanguageSheet(context),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: WoodTheme.wood,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: WoodTheme.gold, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language_rounded,
                  size: 18, color: WoodTheme.cream),
              const SizedBox(width: 8),
              Text(
                _langLabel(appState.lang),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: WoodTheme.cream,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: WoodTheme.cream,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Puzzle slot as wooden gaming card.
class _PuzzleSlotCard extends StatelessWidget {
  const _PuzzleSlotCard({required this.slot});

  final int slot;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final done = GameController.isSlotDoneToday(appState.lang, slot);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => GameScreen.daily(slot: slot)),
      ),
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: done
                ? const [WoodTheme.emerald, WoodTheme.emeraldDeep]
                : [
                    WoodTheme.lighten(WoodTheme.wood, 0.08),
                    WoodTheme.woodDark,
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: done ? WoodTheme.gold : WoodTheme.goldSoft,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
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
              color: WoodTheme.cream,
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium banner - gold gradient (already fits the wood palette).
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
            colors: [WoodTheme.goldSoft, WoodTheme.gold],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: WoodTheme.woodDark, width: 1),
          boxShadow: [
            BoxShadow(
              color: WoodTheme.gold.withValues(alpha: 0.35),
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
              color: WoodTheme.woodDark,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              s.get('premiumTitle'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: WoodTheme.woodDark,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: WoodTheme.woodDark,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

/// Action card for the features grid — wood restyle (no rainbow colors).
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: WoodTheme.cream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: WoodTheme.woodLight.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: WoodTheme.emerald.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: WoodTheme.emerald.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: WoodTheme.emerald, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: WoodTheme.woodDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// v4: zero-size widget that checks the daily login reward once and shows
/// the reward dialog when a new day streak starts.
class _DailyRewardCheck extends StatefulWidget {
  const _DailyRewardCheck();
  @override
  State<_DailyRewardCheck> createState() => _DailyRewardCheckState();
}

class _DailyRewardCheckState extends State<_DailyRewardCheck> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    if (_checked) return;
    _checked = true;
    try {
      final reward = await RewardsService.instance.checkDailyReward();
      if (reward != null && mounted) {
        final s = context.read<AppState>().s;
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: WoodTheme.cream,
            title: Text('🎁 ${s.get('dailyReward')}',
                style:
                    const TextStyle(color: WoodTheme.woodDark)),
            content: Text(
              '${s.get('dailyRewardSub')}\n\n${s.get('comeBackTomorrow')}',
              style: const TextStyle(color: WoodTheme.wood),
            ),
            actions: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: WoodTheme.emerald,
                  foregroundColor: WoodTheme.cream,
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('${s.get('claim')} +${reward.coins} 🪙'),
              ),
            ],
          ),
        );
      }
    } catch (_) {/* rewards must never break home */}
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// v4.1: wooden coin-balance chip shown in the home status bar.
class _WoodCoinChip extends StatelessWidget {
  const _WoodCoinChip();
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CoinsService.instance,
      builder: (context, _) => Container(
        margin: const EdgeInsets.only(right: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: WoodTheme.woodDark.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: WoodTheme.gold, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🪙', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              '${CoinsService.instance.balance}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: WoodTheme.cream,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// v4.2: hints-count pill for the top status bar (matches the coin chip).
class _HintsPill extends StatelessWidget {
  const _HintsPill();
  @override
  Widget build(BuildContext context) {
    int count = 0;
    try {
      count = BoosterService.instance.hintCount;
    } catch (_) {/* never break home */}
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: WoodTheme.woodDark.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WoodTheme.gold, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💡', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: WoodTheme.cream,
            ),
          ),
        ],
      ),
    );
  }
}

/// v4.2: half-width chunky mode button for the WORD FEVER / SCRAMBLE duo
/// row — same wooden luxury treatment as [_ChunkyModeButton], compact.
class _DuoModeButton extends StatelessWidget {
  const _DuoModeButton({
    required this.emoji,
    required this.title,
    required this.badge,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              WoodTheme.lighten(WoodTheme.wood, 0.10),
              WoodTheme.wood,
              WoodTheme.woodDark,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: WoodTheme.gold, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: WoodTheme.gold.withValues(alpha: 0.18),
                border: Border.all(
                    color: WoodTheme.goldSoft, width: 1.5),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(height: 8),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: WoodTheme.cream,
                letterSpacing: 0.8,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: WoodTheme.cream,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: WoodTheme.goldSoft, width: 1),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: WoodTheme.woodDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// v4.2: wide 1v1 CHALLENGE banner — the "play with friends" hero strip
/// (reference: the wide TOGETHER banner). Emerald gradient to stand apart
/// from the wood mode buttons, gold border, tactile press state.
class _ChallengeBanner extends StatelessWidget {
  const _ChallengeBanner({required this.s, required this.onTap});

  final S s;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [WoodTheme.emerald, WoodTheme.emeraldDeep],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: WoodTheme.gold, width: 2),
          boxShadow: [
            BoxShadow(
              color: WoodTheme.emerald
                  .withValues(alpha: 0.45),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: WoodTheme.cream.withValues(alpha: 0.15),
                border: Border.all(
                    color: WoodTheme.goldSoft, width: 1.5),
              ),
              child: const Text('⚔️',
                  style: TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.get('challengeTitle').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: WoodTheme.cream,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.get('challengeBannerSub'),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: WoodTheme.cream
                          .withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: WoodTheme.gold,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'VS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: WoodTheme.woodDark,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// v4.2: wooden bottom shortcut bar — five tappable shortcuts
/// (premium, achievements, stats, how-to-play, settings). Custom built
/// (no state needed) with emerald body and a gold top edge.
class _BottomShortcutBar extends StatelessWidget {
  const _BottomShortcutBar({required this.s});

  final S s;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.shopping_cart_outlined,
        s.get('premiumTitle'),
        () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PremiumScreen()),
        ),
      ),
      (
        Icons.emoji_events_outlined,
        s.get('achievements'),
        () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => const AchievementsScreen()),
        ),
      ),
      (
        Icons.bar_chart_rounded,
        s.get('stats'),
        () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const StatsScreen()),
        ),
      ),
      (
        Icons.menu_book_outlined,
        s.get('howToPlay'),
        () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) =>
                  const HowToPlayScreen(firstLaunch: false)),
        ),
      ),
      (
        Icons.settings_outlined,
        s.get('settings'),
        () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        ),
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        color: WoodTheme.emeraldDeep,
        border: const Border(
          top: BorderSide(color: WoodTheme.gold, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (final (icon, label, onTap) in items)
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon,
                            color: WoodTheme.cream, size: 24),
                        const SizedBox(height: 3),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            color: WoodTheme.cream
                                .withValues(alpha: 0.85),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
