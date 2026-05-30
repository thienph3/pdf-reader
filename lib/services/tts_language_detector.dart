/// Language detection for TTS using Unicode character ranges.
class TtsLanguageDetector {
  static String detectLanguage(String text) {
    final sample = text.length > 500 ? text.substring(0, 500) : text;
    final runes = sample.runes.toList();
    if (runes.isEmpty) return 'en';

    int vi = 0, zh = 0, ja = 0, ko = 0, th = 0, latin = 0;
    for (final r in runes) {
      if (_isVietnamese(r)) { vi++; }
      else if (_isCJK(r)) { zh++; }
      else if (_isHiraganaKatakana(r)) { ja++; }
      else if (_isHangul(r)) { ko++; }
      else if (_isThai(r)) { th++; }
      else if (_isLatin(r)) { latin++; }
    }

    final total = vi + zh + ja + ko + th + latin;
    if (total == 0) return 'en';
    if (vi > 0 && vi / total > 0.05) return 'vi';
    if (ja > 0) return 'ja';
    if (ko > 0 && ko / total > 0.1) return 'ko';
    if (th > 0 && th / total > 0.1) return 'th';
    if (zh > 0 && zh / total > 0.1) return 'zh';
    return 'en';
  }

  static bool _isVietnamese(int r) {
    return (r == 0x0102 || r == 0x0103 || r == 0x00C2 || r == 0x00E2 ||
            r == 0x0110 || r == 0x0111 || r == 0x00CA || r == 0x00EA ||
            r == 0x00D4 || r == 0x00F4 || r == 0x01A0 || r == 0x01A1 ||
            r == 0x01AF || r == 0x01B0 || (r >= 0x1EA0 && r <= 0x1EF9));
  }

  static bool _isCJK(int r) => (r >= 0x4E00 && r <= 0x9FFF) || (r >= 0x3400 && r <= 0x4DBF);
  static bool _isHiraganaKatakana(int r) => (r >= 0x3040 && r <= 0x309F) || (r >= 0x30A0 && r <= 0x30FF);
  static bool _isHangul(int r) => (r >= 0xAC00 && r <= 0xD7AF) || (r >= 0x1100 && r <= 0x11FF);
  static bool _isThai(int r) => r >= 0x0E00 && r <= 0x0E7F;
  static bool _isLatin(int r) => (r >= 0x0041 && r <= 0x007A) || (r >= 0x00C0 && r <= 0x024F);

  static String? findBestLanguageMatch(String langCode, List<String> availableLanguages) {
    const mapping = {'vi': 'vi-VN', 'en': 'en-US', 'zh': 'zh-CN', 'ja': 'ja-JP', 'ko': 'ko-KR', 'th': 'th-TH'};
    final target = mapping[langCode];
    if (target != null && availableLanguages.contains(target)) return target;
    return availableLanguages.where((l) => l.startsWith(langCode)).firstOrNull;
  }

  static String languageDisplayName(String code) {
    const names = {
      'vi-VN': 'Tiếng Việt', 'en-US': 'English (US)', 'en-GB': 'English (UK)',
      'zh-CN': '中文 (简体)', 'zh-TW': '中文 (繁體)', 'ja-JP': '日本語',
      'ko-KR': '한국어', 'fr-FR': 'Français', 'de-DE': 'Deutsch',
      'es-ES': 'Español', 'pt-BR': 'Português', 'th-TH': 'ไทย',
    };
    return names[code] ?? code;
  }
}
