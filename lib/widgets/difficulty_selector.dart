import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../services/difficulty_service.dart';
import '../widgets/wood_theme.dart';

/// Self-contained difficulty control for the Classic puzzle mode (WS4, v4.1).
///
/// Segmented Easy / Normal / Hard control plus a hard-mode switch, styled
/// with the wooden-luxury [WoodTheme]. Reads and writes
/// [DifficultyService.instance] and fires [onChanged] after every change so
/// the host screen can refresh its puzzle.
class DifficultySelector extends StatefulWidget {
  const DifficultySelector({super.key, required this.onChanged});
  final VoidCallback onChanged;

  @override
  State<DifficultySelector> createState() => _DifficultySelectorState();
}

class _DifficultySelectorState extends State<DifficultySelector> {
  final _svc = DifficultyService.instance;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _svc.init().then((_) {
      _svc.addListener(_refresh);
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _svc.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
    widget.onChanged();
  }

  AppLang get _lang =>
      // Fallback to English when no locale is in context (widget is
      // self-contained and may be previewed outside the app).
      Localizations.localeOf(context).languageCode == 'ur'
          ? AppLang.ur
          : Localizations.localeOf(context).languageCode == 'ar'
              ? AppLang.ar
              : Localizations.localeOf(context).languageCode == 'es'
                  ? AppLang.es
                  : AppLang.en;

  String _t(String key) => S(_lang).get(key);

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SizedBox(
          height: 96,
          child: Center(
              child: CircularProgressIndicator(color: WoodTheme.gold)));
    }
    final level = _svc.level;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WoodTheme.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WoodTheme.gold, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_t('difficulty'),
              style: const TextStyle(
                  color: WoodTheme.woodDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 15)),
          const SizedBox(height: 8),
          SegmentedButton<DifficultyLevel>(
            segments: DifficultyLevel.values
                .map((l) => ButtonSegment<DifficultyLevel>(
                      value: l,
                      label: Text(_t(switch (l) {
                        DifficultyLevel.easy => 'difficultyEasy',
                        DifficultyLevel.normal => 'difficultyNormal',
                        DifficultyLevel.hard => 'difficultyHard',
                      })),
                    ))
                .toList(),
            selected: {level},
            onSelectionChanged: (sel) =>
                _svc.setLevel(sel.first).then((_) => widget.onChanged()),
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: WoodTheme.emerald,
              selectedForegroundColor: WoodTheme.cream,
              foregroundColor: WoodTheme.woodDark,
              side: const BorderSide(color: WoodTheme.gold),
            ),
          ),
          const SizedBox(height: 4),
          SwitchListTile(
            value: _svc.hardMode,
            onChanged: (v) =>
                _svc.setHardMode(v).then((_) => widget.onChanged()),
            title: Text(_t('hardMode'),
                style: const TextStyle(
                    color: WoodTheme.woodDark, fontWeight: FontWeight.w700)),
            subtitle: Text(_t('hardModeHint'),
                style: const TextStyle(
                    color: WoodTheme.wood, fontSize: 12)),
            activeThumbColor: WoodTheme.emerald,
            activeTrackColor: WoodTheme.goldSoft,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ],
      ),
    );
  }
}
