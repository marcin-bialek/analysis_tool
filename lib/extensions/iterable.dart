import 'dart:math';

extension IterableNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } on StateError {
      return null;
    }
  }

  T random() {
    final index = Random().nextInt(length);
    return elementAt(index);
  }
}
