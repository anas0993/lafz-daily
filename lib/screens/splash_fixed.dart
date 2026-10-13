import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../game/lang_utils.dart';
import '../main.dart';
import '../services/backend_service.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';
import 'name_entry_screen.dart';
import 'how_to_play_screen.dart';
import 'package:provider/provider.dart';

/// Original branding: gradient tile with ل / L, app name, tagline.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 84});
  final double size;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final letter = appState.lang.isLatin ? 'L' : 'ل';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * 0.55,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final seen =
        StorageService.instance.getBool('howto_seen') ?? false;
    // Check if player name is set - if not, go to name entry first
    final hasName = BackendService.instance.hasPlayerName;
    Widget next;
    if (!hasName) {
      next = const NameEntryScreen();
    } else {
      next = seen ? const HomeScreen() : const HowToPlayScreen(firstLaunch: true);
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final s = appState.s;
    final name = AppConfig.appName(appState.lang);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 96),
            const SizedBox(height: 20),
            Text(name,
                style: const TextStyle(
                    fontSize: 34, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(s.get('tagline'),
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
