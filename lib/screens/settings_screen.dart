import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../services/game_settings.dart';
import '../services/notification_service.dart';
import '../services/share_service.dart';
import '../services/storage_service.dart';
import '../config/app_config.dart';
import '../widgets/animated_background.dart';
import '../widgets/wood_theme.dart';
import '../widgets/audio_settings.dart';
import 'how_to_play_screen.dart';
import 'premium_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _reminderOn = true;

  @override
  void initState() {
    super.initState();
    _reminderOn = NotificationService.instance.isEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.get('settings')),
        backgroundColor: WoodTheme.emerald,
        foregroundColor: WoodTheme.cream,
      ),
      body: AnimatedBackground(
        child: ListView(
          children: [
          // Language
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.language_rounded),
                    const SizedBox(width: 12),
                    Text(
                      s.get('language'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: SegmentedButton<AppLang>(
                    segments: const [
                      ButtonSegment(value: AppLang.en, label: Text('EN')),
                      ButtonSegment(value: AppLang.ur, label: Text('اردو')),
                      ButtonSegment(value: AppLang.ar, label: Text('عربية')),
                      ButtonSegment(value: AppLang.es, label: Text('ES')),
                    ],
                    selected: {appState.lang},
                    onSelectionChanged: (sel) => appState.setLang(sel.first),
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.whatshot_rounded),
            title: Text(s.get('hardMode')),
            subtitle: Text(s.get('hardModeDesc')),
            value: GameSettings.instance.hardMode,
            onChanged: (v) async {
              await GameSettings.instance.setHardMode(v);
              if (mounted) setState(() {});
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.contrast_rounded),
            title: Text(s.get('colorBlind')),
            subtitle: Text(s.get('colorBlindDesc')),
            value: GameSettings.instance.colorBlind,
            onChanged: (v) async {
              await GameSettings.instance.setColorBlind(v);
              if (mounted) setState(() {});
            },
          ),
          const Divider(),
          // Daily reminder
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(s.get('dailyReminder')),
            subtitle: Text(NotificationService.instance.timeLabel),
            value: _reminderOn,
            onChanged: (v) async {
              if (v) {
                final granted = await NotificationService.instance
                    .requestPermission();
                if (!granted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Notification permission denied')),
                  );
                  return;
                }
                await NotificationService.instance.scheduleDaily();
              } else {
                await NotificationService.instance.cancelDaily();
              }
              setState(() => _reminderOn = v);
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule_rounded),
            title: Text(s.get('reminderTime')),
            trailing: Text(NotificationService.instance.timeLabel),
            enabled: _reminderOn,
            onTap: _reminderOn ? () => _pickTime(context) : null,
          ),
          const Divider(),
          // -------------------------------------------------- Sound --
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.volume_up_rounded),
                const SizedBox(width: 12),
                Text(
                  s.get('soundSettings'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const AudioSettingsSection(),
          const Divider(),
          // Premium
          ListTile(
            leading: const Icon(Icons.workspace_premium_rounded,
                color: WoodTheme.gold),
            title: Text(s.get('premiumTitle')),
            subtitle: Text(s.get('premiumFeatures')),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const PremiumScreen()),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title: Text(s.get('howToPlay')),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) =>
                      const HowToPlayScreen(firstLaunch: false)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.share_rounded),
            title: Text(s.get('shareApp')),
            onTap: () => ShareService.share(
                '${s.get('shareText')} ${AppConfig.playStoreUrl}'),
          ),
          ListTile(
            leading: const Icon(Icons.star_outline_rounded),
            title: Text(s.get('rateUs')),
            onTap: () => ShareService.share(AppConfig.playStoreUrl),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(s.get('privacy')),
            onTap: () =>
                ShareService.share(AppConfig.privacyPolicyUrl),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(s.get('terms')),
            onTap: () => ShareService.share(AppConfig.termsUrl),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${s.get('version')} 1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
    );
    if (picked == null) return;
    await StorageService.instance
        .setInt('reminder_minutes', picked.hour * 60 + picked.minute);
    await NotificationService.instance.scheduleDaily();
    if (mounted) setState(() {});
  }
}
