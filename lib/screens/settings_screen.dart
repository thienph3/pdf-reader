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
}
