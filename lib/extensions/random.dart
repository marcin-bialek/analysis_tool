import 'dart:math';

extension RandomElement on Random {
  T element<T>(Iterable<T> iterable) {
    final index = nextInt(iterable.length);
    return iterable.elementAt(index);
  }
}
