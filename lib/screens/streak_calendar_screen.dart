import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/puzzle.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../services/stats_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/wood_theme.dart';

/// Month-view streak calendar (WS4, v4.1).
///
/// Each day shows its daily-puzzle result — win, loss, or not played —
/// taken from [Stats.dayResults] (additive recording, never resets or
/// rewrites history).
class StreakCalendarScreen extends StatefulWidget {
  const StreakCalendarScreen({super.key});

  @override
  State<StreakCalendarScreen> createState() => _StreakCalendarScreenState();
}

class _StreakCalendarScreenState extends State<StreakCalendarScreen> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
  }

  void _shiftMonth(int delta) => setState(() {
        _month = DateTime(_month.year, _month.month + delta, 1);
      });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lang = appState.lang;
    final results = StatsService.instance.get(lang).dayResults;

    String t(String key) => S(lang).get(key);

    final now = DateTime.now();
    final firstOfMonth = _month;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    // Monday-first grid offset.
    final lead = (firstOfMonth.weekday + 6) % 7;
    final canGoForward =
        _month.year < now.year || (_month.year == now.year && _month.month < now.month);

    final weekdayLabels = _weekdayLabels(lang);

    return Scaffold(
      backgroundColor: WoodTheme.cream,
      appBar: AppBar(
        title: Text(t('streakCalendar')),
        backgroundColor: WoodTheme.emerald,
        foregroundColor: WoodTheme.cream,
      ),
      body: AnimatedBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded,
                        color: WoodTheme.woodDark),
                    onPressed: () => _shiftMonth(-1),
                  ),
                  Text(
                    _monthLabel(_month, lang),
                    style: const TextStyle(
                        color: WoodTheme.woodDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right_rounded,
                        color: canGoForward
                            ? WoodTheme.woodDark
                            : WoodTheme.wood.withValues(alpha: 0.3)),
                    onPressed: canGoForward ? () => _shiftMonth(1) : null,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: weekdayLabels
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(d,
                                style: const TextStyle(
                                    color: WoodTheme.wood,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12)),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
                  itemCount: lead + daysInMonth,
                  itemBuilder: (context, i) {
                    if (i < lead) return const SizedBox.shrink();
                    final day = i - lead + 1;
                    final date = DateTime(_month.year, _month.month, day);
                    final isFuture = date.isAfter(
                        DateTime(now.year, now.month, now.day));
                    final result =
                        isFuture ? null : results[Puzzle.dateKey(date)];
                    return _DayCell(
                      day: day,
                      result: result,
                      isToday: date.year == now.year &&
                          date.month == now.month &&
                          date.day == now.day,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  _LegendDot(
                      color: WoodTheme.emerald, label: t('dayWin')),
                  _LegendDot(
                      color: const Color(0xFFB03A2E), label: t('dayLoss')),
                  _LegendDot(
                      color: WoodTheme.creamDeep,
                      label: t('dayNotPlayed'),
                      outline: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthLabel(DateTime m, AppLang lang) {
    const en = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const es = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    const ur = [
      '', 'جنوری', 'فروری', 'مارچ', 'اپریل', 'مئی', 'جون',
      'جولائی', 'اگست', 'ستمبر', 'اکتوبر', 'نومبر', 'دسمبر'
    ];
    const ar = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    final name = switch (lang) {
      AppLang.en => en[m.month],
      AppLang.es => es[m.month],
      AppLang.ur => ur[m.month],
      AppLang.ar => ar[m.month],
    };
    return '$name ${m.year}';
  }

  List<String> _weekdayLabels(AppLang lang) => switch (lang) {
        AppLang.en => const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
        AppLang.es => const ['L', 'M', 'X', 'J', 'V', 'S', 'D'],
        AppLang.ur => const ['پیر', 'منگل', 'بدھ', 'جمعرات', 'جمعہ', 'ہفتہ', 'اتوار'],
        AppLang.ar => const ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'],
      };
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.result, required this.isToday});
  final int day;
  final int? result; // 1 = win, 0 = loss, null = not played
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (result == 1) {
      bg = WoodTheme.emerald;
      fg = WoodTheme.cream;
    } else if (result == 0) {
      bg = const Color(0xFFB03A2E);
      fg = WoodTheme.cream;
    } else {
      bg = WoodTheme.creamDeep.withValues(alpha: 0.55);
      fg = WoodTheme.wood;
    }
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isToday ? WoodTheme.gold : Colors.transparent,
          width: isToday ? 2.5 : 1,
        ),
      ),
      child: Center(
        child: Text('$day',
            style: TextStyle(
                color: fg, fontWeight: FontWeight.w700, fontSize: 14)),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot(
      {required this.color, required this.label, this.outline = false});
  final Color color;
  final String label;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: outline
                ? Border.all(color: WoodTheme.wood)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(color: WoodTheme.woodDark, fontSize: 12)),
      ],
    );
  }
}
