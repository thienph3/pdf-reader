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
      body: ListView(
        children: [
          // Theme
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(s.theme),
            subtitle: Text(_themeName(s, settingsService.themeMode)),
            onTap: () => _showThemePicker(context, s),
          ),
          const Divider(height: 1),

          // Language
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(s.language),
            subtitle: Text(
              settingsService.locale.languageCode == 'vi'
                  ? s.langVi
                  : s.langEn,
            ),
            onTap: () => _showLocalePicker(context, s),
          ),
          const Divider(height: 1),

          // Scroll direction
          ListTile(
            leading: const Icon(Icons.swap_vert),
            title: Text(s.scrollDirection),
            subtitle: Text(settingsService.isHorizontalScroll
                ? s.scrollHorizontal
                : s.scrollVertical),
            onTap: () {
              settingsService
                  .setHorizontalScroll(!settingsService.isHorizontalScroll);
            },
          ),
          const Divider(height: 1),

          // Reading goals
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(s.dailyGoal),
            subtitle: Text(s.minutesPerDay(settingsService.dailyGoalMinutes)),
            onTap: () => _showDailyGoalPicker(context, s),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: Text(s.monthlyGoal),
            subtitle: Text(s.booksPerMonth(settingsService.monthlyGoalBooks)),
            onTap: () => _showMonthlyGoalPicker(context, s),
          ),
        ],
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

  void _showThemePicker(BuildContext context, AppStrings s) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(s.theme),
        children: [
          _themeOption(ctx, s.themeSystem, ThemeMode.system),
          _themeOption(ctx, s.themeLight, ThemeMode.light),
          _themeOption(ctx, s.themeDark, ThemeMode.dark),
        ],
      ),
    );
  }

  Widget _themeOption(BuildContext ctx, String label, ThemeMode mode) {
    final isSelected = settingsService.themeMode == mode;
    return SimpleDialogOption(
      onPressed: () {
        settingsService.setThemeMode(mode);
        Navigator.pop(ctx);
      },
      child: Row(
        children: [
          if (isSelected)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.check, size: 18),
            ),
          Text(label),
        ],
      ),
    );
  }

  void _showLocalePicker(BuildContext context, AppStrings s) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(s.language),
        children: [
          _localeOption(ctx, s.langVi, const Locale('vi')),
          _localeOption(ctx, s.langEn, const Locale('en')),
        ],
      ),
    );
  }

  Widget _localeOption(BuildContext ctx, String label, Locale locale) {
    final isSelected = settingsService.locale.languageCode == locale.languageCode;
    return SimpleDialogOption(
      onPressed: () {
        settingsService.setLocale(locale);
        Navigator.pop(ctx);
      },
      child: Row(
        children: [
          if (isSelected)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.check, size: 18),
            ),
          Text(label),
        ],
      ),
    );
  }

  void _showDailyGoalPicker(BuildContext context, AppStrings s) {
    final options = [10, 15, 20, 30, 45, 60, 90, 120];
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(s.dailyGoal),
        children: options
            .map((m) => SimpleDialogOption(
                  onPressed: () {
                    settingsService.setDailyGoalMinutes(m);
                    Navigator.pop(ctx);
                  },
                  child: Row(
                    children: [
                      if (settingsService.dailyGoalMinutes == m)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.check, size: 18),
                        ),
                      Text(s.minutesPerDay(m)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  void _showMonthlyGoalPicker(BuildContext context, AppStrings s) {
    final options = [1, 2, 3, 4, 5, 8, 10, 12];
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(s.monthlyGoal),
        children: options
            .map((n) => SimpleDialogOption(
                  onPressed: () {
                    settingsService.setMonthlyGoalBooks(n);
                    Navigator.pop(ctx);
                  },
                  child: Row(
                    children: [
                      if (settingsService.monthlyGoalBooks == n)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.check, size: 18),
                        ),
                      Text(s.booksPerMonth(n)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
