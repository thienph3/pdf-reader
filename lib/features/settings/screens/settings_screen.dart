import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../app/main.dart';
import '../../../services/settings_service.dart';
import '../../../services/tts_service.dart';
import '../../../core/utils/dialogs.dart';
import '../widgets/settings_tts_section.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settingsService;
  final TtsService? ttsService;
  const SettingsScreen({super.key, required this.settingsService, this.ttsService});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  SettingsService get settingsService => widget.settingsService;
  TtsService? get ttsService => widget.ttsService;

  @override
  void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); }
  @override
  void dispose() { WidgetsBinding.instance.removeObserver(this); super.dispose(); }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ttsService?.refreshInstalledLanguages();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: ListenableBuilder(
        listenable: settingsService,
        builder: (context, _) => ListView(children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(s.theme),
            subtitle: Text(_themeName(s, settingsService.themeMode)),
            trailing: IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: _cycleTheme),
            onTap: _cycleTheme,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(s.language),
            subtitle: Text(settingsService.locale.languageCode == 'vi' ? s.langVi : s.langEn),
            trailing: Switch(value: settingsService.locale.languageCode == 'en', onChanged: (_) => _toggleLanguage()),
            onTap: _toggleLanguage,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.swap_vert),
            title: Text(s.scrollDirection),
            subtitle: Text(settingsService.isHorizontalScroll ? s.scrollHorizontal : s.scrollVertical),
            trailing: Switch(value: settingsService.isHorizontalScroll, onChanged: (v) => settingsService.setHorizontalScroll(v)),
            onTap: () => settingsService.setHorizontalScroll(!settingsService.isHorizontalScroll),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(s.dailyGoal),
            subtitle: Text(s.minutesPerDay(settingsService.dailyGoalMinutes)),
            trailing: IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: _cycleDailyGoal),
            onTap: _cycleDailyGoal,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: Text(s.monthlyGoal),
            subtitle: Text(s.booksPerMonth(settingsService.monthlyGoalBooks)),
            trailing: IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: _cycleMonthlyGoal),
            onTap: _cycleMonthlyGoal,
          ),
          const Divider(height: 1),
          ListTile(leading: const Icon(Icons.backup_outlined), title: const Text('Backup'), subtitle: const Text('Export all books as JSON'), onTap: () => _handleBackup(context)),
          const Divider(height: 1),
          ListTile(leading: const Icon(Icons.restore), title: const Text('Restore'), subtitle: const Text('Import books from JSON backup'), onTap: () => _handleRestore(context)),
          if (ttsService != null) SettingsTtsSection(ttsService: ttsService!),
        ]),
      ),
    );
  }

  String _themeName(AppStrings s, ThemeMode mode) {
    switch (mode) { case ThemeMode.light: return s.themeLight; case ThemeMode.dark: return s.themeDark; default: return s.themeSystem; }
  }

  void _cycleTheme() {
    final next = switch (settingsService.themeMode) { ThemeMode.system => ThemeMode.light, ThemeMode.light => ThemeMode.dark, ThemeMode.dark => ThemeMode.system };
    settingsService.setThemeMode(next);
  }

  void _toggleLanguage() {
    final next = settingsService.locale.languageCode == 'vi' ? const Locale('en') : const Locale('vi');
    settingsService.setLocale(next);
  }

  void _cycleDailyGoal() {
    const options = [10, 15, 20, 30, 45, 60, 90, 120];
    final i = options.indexOf(settingsService.dailyGoalMinutes);
    settingsService.setDailyGoalMinutes(options[(i + 1) % options.length]);
  }

  void _cycleMonthlyGoal() {
    const options = [1, 2, 3, 4, 5, 8, 10, 12];
    final i = options.indexOf(settingsService.monthlyGoalBooks);
    settingsService.setMonthlyGoalBooks(options[(i + 1) % options.length]);
  }

  Future<void> _handleBackup(BuildContext context) async {
    final bookService = BookServiceScope.of(context);
    final path = await FilePicker.saveFile(dialogTitle: 'Backup', fileName: 'pdf_reader_backup.json');
    if (path == null) return;
    await bookService.backupToFile(path);
    if (context.mounted) showAppSnackBar(context, 'Backup saved');
  }

  Future<void> _handleRestore(BuildContext context) async {
    final bookService = BookServiceScope.of(context);
    final result = await FilePicker.pickFiles(type: FileType.any);
    if (result == null || result.files.single.path == null) return;
    final count = await bookService.importFromFile(result.files.single.path!);
    if (context.mounted) showAppSnackBar(context, 'Restored $count books');
  }
}
