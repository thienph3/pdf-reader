import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'tts_language_detector.dart';
import 'tts_text_cleaner.dart';

enum TtsState { stopped, playing, paused }

/// Service quản lý Text-to-Speech offline với foreground service support.
class TtsService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  TtsState state = TtsState.stopped;
  double speed = 0.5;
  double pitch = 1.0;
  String? currentLanguage;
  List<String> availableLanguages = [];
  Map<String, bool> installedLanguages = {};
  String? currentText;
  bool _isAvailable = false;
  bool _languageNotInstalled = false;

  bool get isPlaying => state == TtsState.playing;
  bool get isPaused => state == TtsState.paused;
  bool get isStopped => state == TtsState.stopped;
  bool get isAvailable => _isAvailable;
  bool get languageNotInstalled => _languageNotInstalled;

  Future<void> init() async {
    try {
      _tts.setStartHandler(() { state = TtsState.playing; notifyListeners(); });
      _tts.setCompletionHandler(() { state = TtsState.stopped; currentText = null; _stopForegroundService(); notifyListeners(); });
      _tts.setCancelHandler(() { state = TtsState.stopped; _stopForegroundService(); notifyListeners(); });
      _tts.setPauseHandler(() { state = TtsState.paused; notifyListeners(); });
      _tts.setContinueHandler(() { state = TtsState.playing; notifyListeners(); });

      final langs = await _tts.getLanguages;
      if (langs != null) availableLanguages = List<String>.from(langs)..sort();
      await refreshInstalledLanguages();
      await _tts.setSpeechRate(speed);
      await _tts.setPitch(pitch);

      if (availableLanguages.any((l) => l.startsWith('vi'))) { await setLanguage('vi-VN'); }
      else if (availableLanguages.any((l) => l.startsWith('en'))) { await setLanguage('en-US'); }

      _initForegroundTask();
      _isAvailable = true;
    } catch (e) {
      debugPrint('TTS init error: $e');
      _isAvailable = false;
    }
  }

  Future<void> refreshInstalledLanguages() async {
    if (!Platform.isAndroid) return;
    const common = ['vi-VN', 'en-US', 'en-GB', 'zh-CN', 'ja-JP', 'ko-KR', 'fr-FR', 'de-DE', 'es-ES', 'pt-BR', 'th-TH'];
    for (final lang in common) {
      if (availableLanguages.contains(lang)) {
        final result = await _tts.isLanguageInstalled(lang);
        installedLanguages[lang] = result == true;
      }
    }
    notifyListeners();
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(channelId: 'pdf_reader_tts', channelName: 'PDF Reader TTS', channelDescription: 'Reading PDF aloud', channelImportance: NotificationChannelImportance.LOW, priority: NotificationPriority.LOW),
      iosNotificationOptions: const IOSNotificationOptions(showNotification: true, playSound: false),
      foregroundTaskOptions: ForegroundTaskOptions(eventAction: ForegroundTaskEventAction.nothing(), autoRunOnBoot: false, autoRunOnMyPackageReplaced: false, allowWakeLock: true, allowWifiLock: false),
    );
  }

  Future<void> _startForegroundService() async {
    if (Platform.isAndroid) {
      final permission = await FlutterForegroundTask.checkNotificationPermission();
      if (permission != NotificationPermission.granted) await FlutterForegroundTask.requestNotificationPermission();
      if (await FlutterForegroundTask.isRunningService) return;
      await FlutterForegroundTask.startService(notificationTitle: 'PDF Reader', notificationText: 'Reading aloud...');
    }
  }

  Future<void> _stopForegroundService() async {
    if (Platform.isAndroid && await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }

  Future<void> setLanguage(String lang) async {
    final result = await _tts.setLanguage(lang);
    if (result == 1) { currentLanguage = lang; _languageNotInstalled = false; notifyListeners(); }
  }

  Future<void> setSpeed(double value) async { speed = value; await _tts.setSpeechRate(speed); notifyListeners(); }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    final cleaned = cleanPdfText(text);
    if (cleaned.isEmpty) return;

    final detected = detectLanguage(cleaned);
    final targetLang = TtsLanguageDetector.findBestLanguageMatch(detected, availableLanguages);
    if (targetLang != null && targetLang != currentLanguage) await setLanguage(targetLang);

    if (currentLanguage != null && Platform.isAndroid) {
      final installed = await _tts.isLanguageInstalled(currentLanguage!);
      if (installed != true) { _languageNotInstalled = true; notifyListeners(); return; }
    }
    _languageNotInstalled = false;
    currentText = cleaned;
    state = TtsState.playing;
    notifyListeners();
    await _startForegroundService();
    await _tts.speak(cleaned);
  }

  Future<void> pause() async { await _tts.pause(); state = TtsState.paused; notifyListeners(); }

  Future<void> stop() async {
    await _tts.stop(); state = TtsState.stopped; currentText = null;
    await _stopForegroundService(); notifyListeners();
  }

  // Keep public API compatible - delegate to extracted classes
  static String detectLanguage(String text) => TtsLanguageDetector.detectLanguage(text);
  static String cleanPdfText(String raw) => TtsTextCleaner.cleanPdfText(raw);
  static String languageDisplayName(String code) => TtsLanguageDetector.languageDisplayName(code);

  @override
  void dispose() { _tts.stop(); _stopForegroundService(); super.dispose(); }
}
