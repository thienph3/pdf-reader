import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../services/tts_service.dart';
import '../../../core/utils/dialogs.dart';
import './tts_dialogs.dart';

/// Bottom panel for TTS controls in PDF viewer.
class PdfTtsPanel extends StatelessWidget {
  final TtsService ttsService;
  final String? pageText;
  final VoidCallback onClose;
  final VoidCallback onPlay;

  const PdfTtsPanel({super.key, required this.ttsService, required this.pageText, required this.onClose, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ttsService,
      builder: (context, _) => ttsService.isAvailable ? _buildControls(context) : _buildUnavailable(context),
    );
  }

  Widget _buildUnavailable(BuildContext context) {
    final s = AppStrings.of(context);
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.volume_off, size: 32),
          const SizedBox(height: 8),
          Text(s.ttsNotAvailable),
          const SizedBox(height: 8),
          if (Platform.isAndroid) FilledButton.tonal(onPressed: () => showAppSnackBar(context, s.androidTtsHint), child: Text(s.ttsHowToEnable)),
          if (Platform.isIOS) Text(s.iosVoiceHint, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final s = AppStrings.of(context);
    final hasText = pageText != null && pageText!.trim().isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.all(12), elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            const Icon(Icons.record_voice_over, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(s.tts, style: const TextStyle(fontWeight: FontWeight.w600))),
            if (ttsService.currentLanguage != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => showTtsLanguagePicker(context, ttsService),
                  child: Chip(label: Text(_shortLang(ttsService.currentLanguage!), style: const TextStyle(fontSize: 11)), visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                ),
              ),
            IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () { ttsService.stop(); onClose(); }, visualDensity: VisualDensity.compact),
          ]),
          Row(children: [
            const Icon(Icons.speed, size: 16),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => ttsService.cycleSpeed(),
              child: Chip(label: Text(ttsService.speedLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
            ),
          ]),
          if (ttsService.sentenceCount > 0)
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(icon: const Icon(Icons.skip_previous), onPressed: ttsService.currentSentenceIndex > 0 ? () => ttsService.prevSentence() : null),
              Text('${ttsService.currentSentenceIndex + 1}/${ttsService.sentenceCount}', style: const TextStyle(fontWeight: FontWeight.w600)),
              IconButton(icon: const Icon(Icons.skip_next), onPressed: ttsService.currentSentenceIndex + 1 < ttsService.sentenceCount ? () => ttsService.nextSentence() : null),
            ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(icon: const Icon(Icons.stop), onPressed: ttsService.isStopped ? null : () => ttsService.stop()),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: hasText ? () { if (ttsService.isPlaying) { ttsService.pause(); } else { onPlay(); } } : null,
              icon: Icon(ttsService.isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(ttsService.isPlaying ? s.ttsPause : s.ttsReadPage),
              style: FilledButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary),
            ),
            const SizedBox(width: 16),
            IconButton(icon: const Icon(Icons.settings_voice), tooltip: s.voiceSettings, onPressed: () => showTtsVoiceSettings(context, ttsService)),
          ]),
          if (!hasText) Padding(padding: const EdgeInsets.only(top: 4, bottom: 4), child: Text(s.noTextOnPage, style: TextStyle(fontSize: 12, color: colorScheme.error))),
          if (ttsService.languageNotInstalled) Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Column(children: [
              Text(s.voiceNotInstalled(ttsService.currentLanguage!), style: TextStyle(fontSize: 12, color: colorScheme.error)),
              const SizedBox(height: 4),
              Text(Platform.isAndroid ? s.androidTtsHint : s.iosVoiceHint, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
            ]),
          ),
        ]),
      ),
    );
  }

  String _shortLang(String lang) => lang.split('-').first.toUpperCase();
}
