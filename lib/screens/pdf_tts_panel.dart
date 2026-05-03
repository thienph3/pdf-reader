import 'dart:io';
import 'package:flutter/material.dart';
import '../services/tts_service.dart';

/// Bottom panel for TTS controls in PDF viewer.
class PdfTtsPanel extends StatelessWidget {
  final TtsService ttsService;
  final String? pageText;
  final VoidCallback onClose;
  final VoidCallback onPlay;

  const PdfTtsPanel({
    super.key,
    required this.ttsService,
    required this.pageText,
    required this.onClose,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ttsService,
      builder: (context, _) {
        if (!ttsService.isAvailable) {
          return _buildUnavailable(context);
        }
        return _buildControls(context);
      },
    );
  }

  Widget _buildUnavailable(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.volume_off, size: 32),
            const SizedBox(height: 8),
            const Text('TTS not available'),
            const SizedBox(height: 8),
            if (Platform.isAndroid)
              FilledButton.tonal(
                onPressed: () {
                  // Guide user to settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Go to Settings > System > Language > Text-to-Speech')),
                  );
                },
                child: const Text('How to enable TTS'),
              ),
            if (Platform.isIOS)
              const Text(
                'Go to Settings > Accessibility > Spoken Content > Voices',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final hasText = pageText != null && pageText!.trim().isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row
            Row(
              children: [
                const Icon(Icons.record_voice_over, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Text-to-Speech',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                // Language indicator
                if (ttsService.currentLanguage != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _showLanguagePicker(context),
                      child: Chip(
                        label: Text(
                          _shortLang(ttsService.currentLanguage!),
                          style: const TextStyle(fontSize: 11),
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    ttsService.stop();
                    onClose();
                  },
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            // Speed slider
            Row(
              children: [
                const Icon(Icons.speed, size: 16),
                Expanded(
                  child: Slider(
                    value: ttsService.speed,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    label: '${(ttsService.speed * 2).toStringAsFixed(1)}x',
                    onChanged: (v) => ttsService.setSpeed(v),
                  ),
                ),
              ],
            ),
            // Play controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Stop
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: ttsService.isStopped ? null : () => ttsService.stop(),
                ),
                const SizedBox(width: 16),
                // Play / Pause
                FilledButton.icon(
                  onPressed: hasText
                      ? () {
                          if (ttsService.isPlaying) {
                            ttsService.pause();
                          } else {
                            onPlay();
                          }
                        }
                      : null,
                  icon: Icon(ttsService.isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(ttsService.isPlaying ? 'Pause' : 'Read Page'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                // TTS Settings (download voices)
                IconButton(
                  icon: const Icon(Icons.settings_voice),
                  tooltip: 'Voice Settings',
                  onPressed: () => _showVoiceSettings(context),
                ),
              ],
            ),
            if (!hasText)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Text(
                  'No text found on this page (scanned PDF?)',
                  style: TextStyle(fontSize: 12, color: colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final langs = ttsService.availableLanguages;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Select Language',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: langs.length,
                itemBuilder: (_, i) {
                  final lang = langs[i];
                  final isSelected = lang == ttsService.currentLanguage;
                  return ListTile(
                    title: Text(lang),
                    trailing: isSelected
                        ? Icon(Icons.check,
                            color: Theme.of(context).colorScheme.primary)
                        : null,
                    selected: isSelected,
                    onTap: () {
                      ttsService.setLanguage(lang);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVoiceSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Voice Settings',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              if (Platform.isAndroid) ...[
                const Text(
                  'To download more voices or languages:\n'
                  'Settings → System → Language → Text-to-Speech',
                  style: TextStyle(fontSize: 13),
                ),
              ],
              if (Platform.isIOS) ...[
                const Text(
                  'To download voices:\n'
                  'Settings → Accessibility → Spoken Content → Voices\n\n'
                  'Select a language and tap the download icon next to a voice.',
                  style: TextStyle(fontSize: 13),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '${ttsService.availableLanguages.length} languages available',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _shortLang(String lang) {
    // "vi-VN" → "VI", "en-US" → "EN"
    final parts = lang.split('-');
    return parts.first.toUpperCase();
  }
}
