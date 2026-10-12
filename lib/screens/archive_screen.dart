import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../services/remote_content_service.dart';
import '../services/storage_service.dart';
import 'game_screen.dart';
import '../game/puzzle.dart';

/// Archive of past daily puzzles (Pro feature).
/// Each row shows the date and whether it was already played.
class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});
  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;
    final today = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: Text(s.get('archive'))),
      body: ListView.builder(
        itemCount: RemoteContentService.instance.effectiveArchiveDays,
        itemBuilder: (context, i) {
          final date = today.subtract(Duration(days: i + 1));
          final key = Puzzle.dateKey(date);
          final saveKey =
              'game_${appState.lang.name}_daily_$key';
          final played =
              StorageService.instance.getJson(saveKey) != null;
          final label = switch (appState.lang) {
            AppLang.en =>
              '${_monthName(date.month)} ${date.day}, ${date.year}',
            AppLang.es =>
              '${date.day} de ${_esMonth(date.month)} de ${date.year}',
            AppLang.ur =>
              '${date.day} ${_urMonth(date.month)} ${date.year}',
            AppLang.ar =>
              '${date.day} ${_arMonth(date.month)} ${date.year}',
          };
          return ListTile(
            leading: Icon(
              played ? Icons.check_circle : Icons.circle_outlined,
              color: played ? Colors.green : null,
            ),
            title: Text(label),
            subtitle: Text(s.puzzleTag(Puzzle.dayNumber(date))),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => GameScreen.dailyAt(date)),
            ),
          );
        },
      ),
    );
  }

  String _monthName(int m) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m];

  String _urMonth(int m) => const [
        '',
        'جنوری',
        'فروری',
        'مارچ',
        'اپریل',
        'مئی',
        'جون',
        'جولائی',
        'اگست',
        'ستمبر',
        'اکتوبر',
        'نومبر',
        'دسمبر'
      ][m];

  String _esMonth(int m) => const [
        '',
        'enero',
        'febrero',
        'marzo',
        'abril',
        'mayo',
        'junio',
        'julio',
        'agosto',
        'septiembre',
        'octubre',
        'noviembre',
        'diciembre'
      ][m];

  String _arMonth(int m) => const [
        '',
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر'
      ][m];
}
