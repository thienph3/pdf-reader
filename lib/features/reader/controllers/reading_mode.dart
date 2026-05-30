enum ReadingMode {
  normal, // 0
  sepia,  // 1
  dark,   // 2
}

class CropLevel {
  static const values = [0, 10, 15, 20, 25];

  static int next(int current) {
    final i = values.indexOf(current);
    return values[(i + 1) % values.length];
  }
}
