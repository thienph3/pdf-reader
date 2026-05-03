import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsService settingsService;

  const SettingsScreen({super.key, required this.settingsService});

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

          // Monthly goal - Cycle through common options
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


}
