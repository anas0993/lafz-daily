import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../services/audio_service.dart';

/// Settings section with music/SFX toggles. Inserted into the settings
/// screen. (Translations live in the core strings table.)
class AudioSettingsSection extends StatelessWidget {
  const AudioSettingsSection({super.key});

  @override
  Widget build(BuildContext context) => const _AudioToggles();
}

class _AudioToggles extends StatefulWidget {
  const _AudioToggles();

  @override
  State<_AudioToggles> createState() => _AudioTogglesState();
}

class _AudioTogglesState extends State<_AudioToggles> {
  String _t(AppLang lang, String key) => S(lang).get(key);

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().lang;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.music_note_rounded),
          title: Text(_t(lang, 'music')),
          value: AudioService.musicOn,
          onChanged: (v) async {
            await AudioService.setMusicOn(v);
            if (mounted) setState(() {});
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.volume_up_rounded),
          title: Text(_t(lang, 'soundEffects')),
          value: AudioService.sfxOn,
          onChanged: (v) async {
            await AudioService.setSfxOn(v);
            if (mounted) setState(() {});
          },
        ),
      ],
    );
  }
}
