import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

enum TtsState { stopped, playing, paused }

/// Service quản lý Text-to-Speech offline với foreground service support.
class TtsService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  TtsState state = TtsState.stopped;
  double speed = 0.5;
  double pitch = 1.0;
  String? currentLanguage;
  List<String> availableLanguages = [];
  String? currentText;
  bool _isAvailable = false;

  bool get isPlaying => state == TtsState.playing;
  bool get isPaused => state == TtsState.paused;
  bool get isStopped => state == TtsState.stopped;
  bool get isAvailable => _isAvailable;

  Future<void> init() async {
    try {
      _tts.setStartHandler(() {
        state = TtsState.playing;
        notifyListeners();
      });
      _tts.setCompletionHandler(() {
        state = TtsState.stopped;
        currentText = null;
        _stopForegroundService();
        notifyListeners();
      });
      _tts.setCancelHandler(() {
        state = TtsState.stopped;
        _stopForegroundService();
        notifyListeners();
      });
      _tts.setPauseHandler(() {
        state = TtsState.paused;
        notifyListeners();
      });
      _tts.setContinueHandler(() {
        state = TtsState.playing;
        notifyListeners();
      });

      final langs = await _tts.getLanguages;
      if (langs != null) {
        availableLanguages = List<String>.from(langs)..sort();
      }

      await _tts.setSpeechRate(speed);
      await _tts.setPitch(pitch);

      if (availableLanguages.any((l) => l.startsWith('vi'))) {
        await setLanguage('vi-VN');
      } else if (availableLanguages.any((l) => l.startsWith('en'))) {
        await setLanguage('en-US');
      }

      _initForegroundTask();
      _isAvailable = true;
    } catch (e) {
      debugPrint('TTS init error: $e');
      _isAvailable = false;
    }
  }

  // ── Foreground service ──

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'pdf_reader_tts',
        channelName: 'PDF Reader TTS',
        channelDescription: 'Reading PDF aloud',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  Future<void> _startForegroundService() async {
    if (Platform.isAndroid) {
      final permission = await FlutterForegroundTask.checkNotificationPermission();
      if (permission != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
      if (await FlutterForegroundTask.isRunningService) return;
      await FlutterForegroundTask.startService(
        notificationTitle: 'PDF Reader',
        notificationText: 'Reading aloud...',
      );
    }
  }

  Future<void> _stopForegroundService() async {
    if (Platform.isAndroid) {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
    }
  }

  // ── TTS controls ──

  Future<void> setLanguage(String lang) async {
    final result = await _tts.setLanguage(lang);
    if (result == 1) {
      currentLanguage = lang;
      notifyListeners();
    }
  }

  Future<void> setSpeed(double value) async {
    speed = value;
    await _tts.setSpeechRate(speed);
    notifyListeners();
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    final cleaned = cleanPdfText(text);
    if (cleaned.isEmpty) return;
    currentText = cleaned;
    state = TtsState.playing;
    notifyListeners();
    await _startForegroundService();
    await _tts.speak(cleaned);
  }

  Future<void> pause() async {
    await _tts.pause();
    state = TtsState.paused;
    notifyListeners();
  }

  Future<void> stop() async {
    await _tts.stop();
    state = TtsState.stopped;
    currentText = null;
    await _stopForegroundService();
    notifyListeners();
  }

  bool isLanguageAvailable(String langCode) {
    return availableLanguages.any((l) => l.startsWith(langCode));
  }

  // ── Text cleaning ──

  static String cleanPdfText(String raw) {
    final lines = raw.split('\n');
    final buffer = StringBuffer();

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trimRight();
      if (line.isEmpty) {
        buffer.write('\n\n');
        continue;
      }

      buffer.write(line);

      final isLast = i == lines.length - 1;
      if (isLast) break;

      final nextLine = lines[i + 1].trim();
      if (nextLine.isEmpty) continue;

      final endsWithPunctuation = RegExp(r'[.!?:;。！？]\s*$').hasMatch(line);
      final nextStartsUpper = nextLine.isNotEmpty &&
          nextLine[0] == nextLine[0].toUpperCase() &&
          nextLine[0] != nextLine[0].toLowerCase();

      if (endsWithPunctuation || nextStartsUpper) {
        buffer.write('\n');
      } else {
        buffer.write(' ');
      }
    }

    return buffer.toString()
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();
  }

  @override
  void dispose() {
    _tts.stop();
    _stopForegroundService();
    super.dispose();
  }
}
