class Util {
  static String clean(String text) {
    try {
      String result = text;
      final chars = [
        '"',
        "'",
        ',',
        '.',
        '?',
        '!',
        '-',
        ';',
        ':',
        '’',
        '‘',
        '(',
        ')',
        '[',
        ']',
        '“',
        '”',
      ];

      while (true) {
        if (chars.contains(result[0])) {
          result = result.substring(1);
          continue;
        } else if (chars.contains(result[result.length - 1])) {
          result = result.substring(0, result.length - 1);
          continue;
        }
        break;
      }
      return result;
    } catch (e) {
      return text;
    }
  }
}
