import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/points_service.dart';
import 'services/stats_service.dart';
import 'dart:async';
import 'game/lang_utils.dart';
import 'l10n/strings.dart';
import 'screens/splash_screen.dart';
import 'services/ads_service.dart';
import 'services/backend_service.dart';
import 'services/billing_service.dart';
import 'services/notification_service.dart';
import 'services/remote_content_service.dart';
import 'services/storage_service.dart';

/// Global app state: the single language setting (EN/اردو/عربية/ES),
/// persisted. The setting switches both the UI and the puzzle language.
class AppState extends ChangeNotifier {
  AppLang lang = AppLang.en;

  Future<void> init() async {
    final code = StorageService.instance.getString('app_lang') ?? 'en';
    lang = appLangFromCode(code);
  }

  Future<void> setLang(AppLang l) async {
    if (lang == l) return;
    lang = l;
    await StorageService.instance.setString('app_lang', l.name);
    // Re-schedule the reminder so its text matches the new language.
    if (NotificationService.instance.isEnabled) {
      await NotificationService.instance.scheduleDaily();
    }
    notifyListeners();
  }

  S get s => S(lang);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local storage first — everything else depends on it.
  await StorageService.instance.init();

  final appState = AppState();
  await appState.init();

  // Backend (Supabase): initialize for server-side win tracking.
  // Best-effort: the game works fully offline without it.
  try {
    await BackendService.instance.init();
  } catch (_) {}

  // Ads, billing and notifications initialize best-effort: the game works
  // fully offline without them.
  //
  // Remote content (admin panel via Firebase): fire-and-forget. If Firebase
  // isn't configured yet, this silently keeps the bundled word lists and
  // default settings.
  unawaited(RemoteContentService.instance.init());
  try {
    await AdsService.instance.init();
  } catch (_) {}
  try {
    await BillingService.instance.init();
  } catch (_) {}
  try {
    await NotificationService.instance.init();
  } catch (_) {}

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider.value(value: PointsService.instance),
        ChangeNotifierProvider.value(value: StatsService.instance),
      ],
      child: const LafzDailyApp(),
    ),
  );
}

class LafzDailyApp extends StatelessWidget {
  const LafzDailyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    const seed = Color(0xFF0F766E);
    return MaterialApp(
      title: 'Lafz Daily',
      debugShowCheckedModeBanner: false,
      locale: Locale(appState.lang.name),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: seed, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      builder: (context, child) => Directionality(
        textDirection:
            appState.lang.isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
    );
  }
}
