import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_strings.dart';
import '../services/tts_service.dart';
import '../utils/dialogs.dart';

class SettingsTtsSection extends StatelessWidget {
  final TtsService ttsService;
  const SettingsTtsSection({super.key, required this.ttsService});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return ListenableBuilder(
      listenable: ttsService,
      builder: (context, _) => Column(children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(s.tts, style: Theme.of(context).textTheme.titleSmall),
        ),
        ListTile(
          leading: const Icon(Icons.record_voice_over),
          title: Text(ttsService.isAvailable ? s.ttsAvailable : s.ttsNotAvailable),
          subtitle: Text(ttsService.isAvailable ? s.languagesAvailable(ttsService.availableLanguages.length) : s.noTtsEngine),
          trailing: Icon(ttsService.isAvailable ? Icons.check_circle : Icons.error_outline, color: ttsService.isAvailable ? Colors.green : Colors.red),
        ),
        if (ttsService.isAvailable)
          ...['vi-VN', 'en-US', 'en-GB', 'zh-CN', 'ja-JP', 'ko-KR', 'fr-FR', 'de-DE', 'es-ES', 'th-TH']
              .where((l) => ttsService.availableLanguages.contains(l))
              .map((lang) {
            final installed = ttsService.installedLanguages[lang];
            return ListTile(
              dense: true,
              leading: const SizedBox(width: 24),
              title: Text(TtsService.languageDisplayName(lang)),
              trailing: Icon(installed == true ? Icons.download_done : Icons.download_outlined, size: 20, color: installed == true ? Colors.green : Colors.orange),
              onTap: installed != true ? () => _showInstallHint(context, s) : null,
            );
          }),
      ]),
    );
  }

  static void _showInstallHint(BuildContext context, AppStrings s) {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(s.downloadVoice),
          content: Text(s.downloadVoiceHint),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
            FilledButton(onPressed: () { Navigator.pop(ctx); const MethodChannel('com.thienph3.pdfreader/tts').invokeMethod('openTtsSettings').catchError((_) {}); }, child: Text(s.openTtsSettings)),
          ],
        ),
      );
    } else {
      showAppSnackBar(context, s.iosVoiceHint);
    }
  }
}
