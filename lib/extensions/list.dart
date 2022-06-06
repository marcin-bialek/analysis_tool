extension SortedList<T> on List<T> {
  List<T> sorted([int Function(T, T)? compare]) {
    final list = List<T>.from(this);
    list.sort(compare);
    return list;
  }
}
