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

      // Check which languages are installed (Android only)
      await refreshInstalledLanguages();

      await _tts.setSpeechRate(speed);
      await _tts.setPitch(pitch);

      // Default language
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

  /// Refresh installed language status.
  Future<void> refreshInstalledLanguages() async {
    if (!Platform.isAndroid) return;
    final common = ['vi-VN', 'en-US', 'en-GB', 'zh-CN', 'ja-JP', 'ko-KR',
                     'fr-FR', 'de-DE', 'es-ES', 'pt-BR', 'th-TH'];
    for (final lang in common) {
      if (availableLanguages.contains(lang)) {
        final result = await _tts.isLanguageInstalled(lang);
        installedLanguages[lang] = result == true;
      }
    }
    notifyListeners();
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
      _languageNotInstalled = false;
      notifyListeners();
    }
  }

  Future<void> setSpeed(double value) async {
    speed = value;
    await _tts.setSpeechRate(speed);
    notifyListeners();
  }

  /// Speak text. Auto-detects language and switches if needed.
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    final cleaned = cleanPdfText(text);
    if (cleaned.isEmpty) return;

    // Auto-detect language and switch
    final detected = detectLanguage(cleaned);
    final targetLang = _findBestLanguageMatch(detected);
    if (targetLang != null && targetLang != currentLanguage) {
      await setLanguage(targetLang);
    }

    // Check if language is installed
    if (currentLanguage != null && Platform.isAndroid) {
      final installed = await _tts.isLanguageInstalled(currentLanguage!);
      if (installed != true) {
        _languageNotInstalled = true;
        notifyListeners();
        return;
      }
    }
    _languageNotInstalled = false;

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

  // ── Language detection (rule-based) ──

  /// Detect language from text using Unicode character ranges.
  static String detectLanguage(String text) {
    final sample = text.length > 500 ? text.substring(0, 500) : text;
    final runes = sample.runes.toList();
    if (runes.isEmpty) return 'en';

    int vi = 0, zh = 0, ja = 0, ko = 0, th = 0, latin = 0;

    for (final r in runes) {
      if (_isVietnamese(r)) {
        vi++;
      } else if (_isCJK(r)) {
        zh++;
      } else if (_isHiraganaKatakana(r)) {
        ja++;
      } else if (_isHangul(r)) {
        ko++;
      } else if (_isThai(r)) {
        th++;
      } else if (_isLatin(r)) {
        latin++;
      }
    }

    // Vietnamese uses Latin + diacritics, so check vi ratio vs latin
    final total = vi + zh + ja + ko + th + latin;
    if (total == 0) return 'en';

    if (vi > 0 && vi / total > 0.05) return 'vi';
    if (ja > 0) return 'ja'; // Hiragana/Katakana = definitely Japanese
    if (ko > 0 && ko / total > 0.1) return 'ko';
    if (th > 0 && th / total > 0.1) return 'th';
    if (zh > 0 && zh / total > 0.1) return 'zh';
    return 'en';
  }

  // Vietnamese diacritics: ă â đ ê ô ơ ư + combining marks
  static bool _isVietnamese(int r) {
    return (r == 0x0102 || r == 0x0103 || // Ă ă
            r == 0x00C2 || r == 0x00E2 || // Â â
            r == 0x0110 || r == 0x0111 || // Đ đ
            r == 0x00CA || r == 0x00EA || // Ê ê
            r == 0x00D4 || r == 0x00F4 || // Ô ô
            r == 0x01A0 || r == 0x01A1 || // Ơ ơ
            r == 0x01AF || r == 0x01B0 || // Ư ư
            // Vowels with tone marks
            (r >= 0x1EA0 && r <= 0x1EF9));
  }

  static bool _isCJK(int r) =>
      (r >= 0x4E00 && r <= 0x9FFF) || (r >= 0x3400 && r <= 0x4DBF);

  static bool _isHiraganaKatakana(int r) =>
      (r >= 0x3040 && r <= 0x309F) || (r >= 0x30A0 && r <= 0x30FF);

  static bool _isHangul(int r) =>
      (r >= 0xAC00 && r <= 0xD7AF) || (r >= 0x1100 && r <= 0x11FF);

  static bool _isThai(int r) => r >= 0x0E00 && r <= 0x0E7F;

  static bool _isLatin(int r) =>
      (r >= 0x0041 && r <= 0x007A) || (r >= 0x00C0 && r <= 0x024F);

  /// Find best matching TTS language code for detected language.
  String? _findBestLanguageMatch(String langCode) {
    // Map detected code to TTS language codes
    final mapping = {
      'vi': 'vi-VN',
      'en': 'en-US',
      'zh': 'zh-CN',
      'ja': 'ja-JP',
      'ko': 'ko-KR',
      'th': 'th-TH',
    };
    final target = mapping[langCode];
    if (target != null && availableLanguages.contains(target)) {
      return target;
    }
    // Try prefix match
    final match = availableLanguages.where((l) => l.startsWith(langCode)).firstOrNull;
    return match;
  }

  /// Get human-readable language name.
  static String languageDisplayName(String code) {
    const names = {
      'vi-VN': 'Tiếng Việt',
      'en-US': 'English (US)',
      'en-GB': 'English (UK)',
      'zh-CN': '中文 (简体)',
      'zh-TW': '中文 (繁體)',
      'ja-JP': '日本語',
      'ko-KR': '한국어',
      'fr-FR': 'Français',
      'de-DE': 'Deutsch',
      'es-ES': 'Español',
      'pt-BR': 'Português',
      'th-TH': 'ไทย',
    };
    return names[code] ?? code;
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

    return buffer
        .toString()
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
