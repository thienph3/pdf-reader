import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../services/tts_service.dart';

void showTtsLanguagePicker(BuildContext context, TtsService ttsService) {
  final s = AppStrings.of(context);
  final langs = ttsService.availableLanguages;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.5, maxChildSize: 0.8, minChildSize: 0.3, expand: false,
      builder: (_, scrollCtrl) => Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Text(s.selectLanguage, style: Theme.of(context).textTheme.titleMedium)),
        Expanded(child: ListView.builder(
          controller: scrollCtrl, itemCount: langs.length,
          itemBuilder: (_, i) {
            final lang = langs[i];
            final isSelected = lang == ttsService.currentLanguage;
            return ListTile(
              title: Text(lang),
              trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
              selected: isSelected,
              onTap: () { ttsService.setLanguage(lang); Navigator.pop(ctx); },
            );
          },
        )),
      ]),
    ),
  );
}

void showTtsVoiceSettings(BuildContext context, TtsService ttsService) {
  final s = AppStrings.of(context);
  showModalBottomSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.voiceSettings, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (Platform.isAndroid) Text(s.androidTtsHint, style: const TextStyle(fontSize: 13)),
          if (Platform.isIOS) Text(s.iosVoiceHint, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 8),
          Text(s.languagesAvailable(ttsService.availableLanguages.length), style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
    ),
  );
}
