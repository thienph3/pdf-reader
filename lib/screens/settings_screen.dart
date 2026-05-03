import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_strings.dart';
import '../services/settings_service.dart';
import '../services/tts_service.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settingsService;
  final TtsService? ttsService;

  const SettingsScreen({
    super.key,
    required this.settingsService,
    this.ttsService,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  SettingsService get settingsService => widget.settingsService;
  TtsService? get ttsService => widget.ttsService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh TTS installed languages when returning from settings
      ttsService?.refreshInstalledLanguages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: ListenableBuilder(
        listenable: settingsService,
        builder: (context, _) => ListView(
        children: [
          // Theme - Cycle through 3 options
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(s.theme),
            subtitle: Text(_themeName(s, settingsService.themeMode)),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => _cycleTheme(),
            ),
            onTap: () => _cycleTheme(),
          ),
          const Divider(height: 1),

          // Language - Toggle between 2 options
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(s.language),
            subtitle: Text(
              settingsService.locale.languageCode == 'vi'
                  ? s.langVi
                  : s.langEn,
            ),
            trailing: Switch(
              value: settingsService.locale.languageCode == 'en',
              onChanged: (_) => _toggleLanguage(),
            ),
            onTap: () => _toggleLanguage(),
          ),
          const Divider(height: 1),

          // Scroll direction - Already a toggle
          ListTile(
            leading: const Icon(Icons.swap_vert),
            title: Text(s.scrollDirection),
            subtitle: Text(settingsService.isHorizontalScroll
                ? s.scrollHorizontal
                : s.scrollVertical),
            trailing: Switch(
              value: settingsService.isHorizontalScroll,
              onChanged: (value) => settingsService.setHorizontalScroll(value),
            ),
            onTap: () {
              settingsService
                  .setHorizontalScroll(!settingsService.isHorizontalScroll);
            },
          ),
          const Divider(height: 1),

          // Daily goal - Cycle through common options
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(s.dailyGoal),
            subtitle: Text(s.minutesPerDay(settingsService.dailyGoalMinutes)),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => _cycleDailyGoal(),
            ),
            onTap: () => _cycleDailyGoal(),
          ),
          const Divider(height: 1),

          // Monthly goal
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: Text(s.monthlyGoal),
            subtitle: Text(s.booksPerMonth(settingsService.monthlyGoalBooks)),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => _cycleMonthlyGoal(),
            ),
            onTap: () => _cycleMonthlyGoal(),
          ),

          // TTS section
          if (ttsService != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Text-to-Speech',
                  style: Theme.of(context).textTheme.titleSmall),
            ),
            ListenableBuilder(
              listenable: ttsService!,
              builder: (context, _) => Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.record_voice_over),
                    title: Text(ttsService!.isAvailable
                        ? 'TTS Available'
                        : 'TTS Not Available'),
                    subtitle: Text(ttsService!.isAvailable
                        ? '${ttsService!.availableLanguages.length} languages'
                        : 'No TTS engine found'),
                    trailing: Icon(
                      ttsService!.isAvailable
                          ? Icons.check_circle
                          : Icons.error_outline,
                      color: ttsService!.isAvailable
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  if (ttsService!.isAvailable)
                    ...['vi-VN', 'en-US', 'en-GB', 'zh-CN', 'ja-JP', 'ko-KR',
                        'fr-FR', 'de-DE', 'es-ES', 'th-TH']
                        .where((l) => ttsService!.availableLanguages.contains(l))
                        .map((lang) {
                      final installed = ttsService!.installedLanguages[lang];
                      return ListTile(
                        dense: true,
                        leading: const SizedBox(width: 24),
                        title: Text(TtsService.languageDisplayName(lang)),
                        trailing: Icon(
                          installed == true
                              ? Icons.download_done
                              : Icons.download_outlined,
                          size: 20,
                          color: installed == true
                              ? Colors.green
                              : Colors.orange,
                        ),
                        onTap: installed != true
                            ? () => _showInstallHint(context)
                            : null,
                      );
                    }),
                ],
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  String _themeName(AppStrings s, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return s.themeLight;
      case ThemeMode.dark:
        return s.themeDark;
      default:
        return s.themeSystem;
    }
  }

  void _cycleTheme() {
    final current = settingsService.themeMode;
    ThemeMode next;
    
    switch (current) {
      case ThemeMode.system:
        next = ThemeMode.light;
        break;
      case ThemeMode.light:
        next = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        next = ThemeMode.system;
        break;
    }
    
    settingsService.setThemeMode(next);
  }

  void _toggleLanguage() {
    final current = settingsService.locale.languageCode;
    final next = current == 'vi' ? const Locale('en') : const Locale('vi');
    settingsService.setLocale(next);
  }

  void _cycleDailyGoal() {
    final options = [10, 15, 20, 30, 45, 60, 90, 120];
    final current = settingsService.dailyGoalMinutes;
    final currentIndex = options.indexOf(current);
    final nextIndex = (currentIndex + 1) % options.length;
    settingsService.setDailyGoalMinutes(options[nextIndex]);
  }

  void _cycleMonthlyGoal() {
    final options = [1, 2, 3, 4, 5, 8, 10, 12];
    final current = settingsService.monthlyGoalBooks;
    final currentIndex = options.indexOf(current);
    final nextIndex = (currentIndex + 1) % options.length;
    settingsService.setMonthlyGoalBooks(options[nextIndex]);
  }

  void _showInstallHint(BuildContext context) {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Download Voice'),
          content: const Text(
            'To download this voice, open your device\'s TTS settings.\n\n'
            'Settings → System → Language → Text-to-Speech → Install voice data',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Open Android TTS settings via intent
                const channel = MethodChannel('com.example.pdf_reader/tts');
                channel.invokeMethod('openTtsSettings').catchError((_) {});
              },
              child: const Text('Open TTS Settings'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Go to Settings → Accessibility → Spoken Content → Voices'),
        ),
      );
    }
  }


}
