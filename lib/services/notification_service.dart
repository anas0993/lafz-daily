import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../game/lang_utils.dart';
import '../game/puzzle.dart';
import '../l10n/strings.dart';
import 'storage_service.dart';

/// Daily reminder notification ("your daily word is waiting").
/// Time is user-configurable (default 09:00). Uses the device timezone.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const int _dailyId = 1001;

  Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('Timezone setup failed, using UTC: $e');
      tz.setLocalLocation(tz.UTC);
    }
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: androidInit));
    _ready = true;
    // Apply the saved preference on every launch.
    final enabled =
        StorageService.instance.getBool('reminder_enabled') ?? true;
    if (enabled) {
      await scheduleDaily();
    }
  }

  /// Android 13+ needs runtime permission for notifications.
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? true;
  }

  Future<void> scheduleDaily() async {
    if (!_ready) return;
    final store = StorageService.instance;
    final minutes = store.getInt('reminder_minutes') ?? 9 * 60;
    final langCode = store.getString('app_lang') ?? 'en';
    final s = S(appLangFromCode(langCode));

    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day,
        minutes ~/ 60, minutes % 60);
    if (when.isBefore(now)) {
      when = when.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      _dailyId,
      s.get('notifTitle'),
      s.get('reminderBody'),
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily reminder',
          importance: Importance.defaultImportance,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    await store.setBool('reminder_enabled', true);
  }

  Future<void> cancelDaily() async {
    await _plugin.cancel(_dailyId);
    await StorageService.instance.setBool('reminder_enabled', false);
  }

  bool get isEnabled =>
      StorageService.instance.getBool('reminder_enabled') ?? true;

  String get timeLabel {
    final m = StorageService.instance.getInt('reminder_minutes') ?? 9 * 60;
    final h = m ~/ 60;
    final mm = (m % 60).toString().padLeft(2, '0');
    final suffix = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$mm $suffix';
  }
}

/// Helper for the date-key of "today" used by streak logic.
String todayKey() => Puzzle.dateKey(DateTime.now());
