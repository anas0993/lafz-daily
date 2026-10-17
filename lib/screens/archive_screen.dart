import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../services/remote_content_service.dart';
import '../services/storage_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/wood_theme.dart';
import 'game_screen.dart';
import '../game/puzzle.dart';

/// Archive of past daily puzzles (WS4, v4.1).
///
/// Each row shows a past date and whether it was already played. Tapping a
/// date loads that day's puzzle via [GameScreen.dailyAt], which derives the
/// answer with the date-seeded [Puzzle.dailyAnswerForSlot] generator.
/// Replays save under their own date-scoped key, so today's progress,
/// streak and today's stats are never disturbed (see StatsService: the
/// streak only ever reacts to today's dateKey).
class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});
  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  AppLang _langOf(BuildContext context) =>
      Provider.of<AppState>(context, listen: false).lang;

  String _t(String key) => S(_langOf(context)).get(key);

  DateTime get _today => DateTime.now();

  Future<void> _pickDate() async {
    final maxPast =
        RemoteContentService.instance.effectiveArchiveDays.clamp(1, 3650);
    final now = _today;
    final first = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: maxPast));
    final last =
        DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: last,
      firstDate: first,
      lastDate: last,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: WoodTheme.emerald,
            onPrimary: WoodTheme.cream,
            surface: WoodTheme.cream,
            onSurface: WoodTheme.woodDark,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: WoodTheme.cream),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => GameScreen.dailyAt(picked)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;
    final today = _today;
    final days = RemoteContentService.instance.effectiveArchiveDays;
    return Scaffold(
      backgroundColor: WoodTheme.cream,
      appBar: AppBar(
        title: Text(s.get('archive')),
        backgroundColor: WoodTheme.emerald,
        foregroundColor: WoodTheme.cream,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: _t('pickDate'),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: AnimatedBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                _t('archiveHint'),
                style: const TextStyle(color: WoodTheme.wood, fontSize: 13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text(_t('pickDate')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: WoodTheme.emerald,
                  foregroundColor: WoodTheme.cream,
                ),
                onPressed: _pickDate,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: days,
                itemBuilder: (context, i) {
                  final date = today.subtract(Duration(days: i + 1));
                  final key = Puzzle.dateKey(date);
                  final saveKey =
                      'game_${appState.lang.name}_daily_$key';
                  final played =
                      StorageService.instance.getJson(saveKey) != null;
                  final label = _dateLabel(date, appState.lang);
                  return Card(
                    color: WoodTheme.cream.withValues(alpha: 0.92),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                          color: WoodTheme.gold, width: 1),
                    ),
                    child: ListTile(
                      leading: Icon(
                        played
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: played
                            ? WoodTheme.emerald
                            : WoodTheme.wood,
                      ),
                      title: Text(label,
                          style: const TextStyle(
                              color: WoodTheme.woodDark,
                              fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        s.puzzleTag(Puzzle.dayNumber(date)),
                        style: const TextStyle(color: WoodTheme.wood),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: WoodTheme.gold),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => GameScreen.dailyAt(date)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel(DateTime date, AppLang lang) {
    switch (lang) {
      case AppLang.en:
        return '${_monthName(date.month)} ${date.day}, ${date.year}';
      case AppLang.es:
        return '${date.day} de ${_esMonth(date.month)} de ${date.year}';
      case AppLang.ur:
        return '${date.day} ${_urMonth(date.month)} ${date.year}';
      case AppLang.ar:
        return '${date.day} ${_arMonth(date.month)} ${date.year}';
    }
  }

  String _monthName(int m) => const [
        '',
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];

  String _urMonth(int m) => const [
        '',
        'جنوری', 'فروری', 'مارچ', 'اپریل', 'مئی', 'جون',
        'جولائی', 'اگست', 'ستمبر', 'اکتوبر', 'نومبر', 'دسمبر'
      ][m];

  String _esMonth(int m) => const [
        '',
        'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
        'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
      ][m];

  String _arMonth(int m) => const [
        '',
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ][m];
}
