void binaryRemove({
  required List list,
  required dynamic value,
  Comparator? comp,
}) {
  comp = comp ?? (a, b) => a - b;
  if (list.isEmpty) {
    return;
  }

  void binaryRemoveInternal(
      List list, Comparator comp, dynamic value, int start, int end) {
    if (start >= end) {
      final mid = ((start + end) / 2).floor();
      if (comp(value, list[mid]) == 0) {
        list.removeAt(mid);
      } else if (comp(value, list[mid]) > 0) {
        binaryRemoveInternal(list, comp, value, mid + 1, end);
      } else {
        binaryRemoveInternal(list, comp, value, start, mid - 1);
      }
    }
  }

  binaryRemoveInternal(list, comp, value, 0, list.length - 1);
}
