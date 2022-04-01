int binarySearch({
  required List list,
  required dynamic value,
  Comparator? comp,
}) {
  comp = comp ?? (a, b) => a - b;
  // Quick returns
  if (list.isEmpty) {
    return -1;
  }
  if (comp(list[0], value) == 0) {
    return 0;
  }
  if (comp(list[list.length - 1], value) == 0) {
    return list.length - 1;
  }

  int binarySearchInternal(
      List list, Comparator comp, dynamic value, int start, int end) {
    if (end >= start) {
      final mid = ((start + end) / 2).floor();
      if (comp(value, list[mid]) == 0) {
        return mid;
      } else if (comp(value, list[mid]) > 0) {
        return binarySearchInternal(list, comp, value, mid + 1, end);
      } else {
        return binarySearchInternal(list, comp, value, start, mid - 1);
      }
    }
    return -1;
  }

  return binarySearchInternal(list, comp, value, 0, list.length - 1);
}

bool binaryRemove({
  required List list,
  required dynamic value,
  Comparator? comp,
}) {
  var found = binarySearch(
    list: list,
    value: value,
    comp: comp,
  );
  if (found != -1) {
    list.removeAt(found);
    return true;
  }
  return false;
}

//bool binaryInsert({
//  required List list,
//  required dynamic value,
//  Comparator? comp,
//}) {
//  var found = binarySearch(
//    list: list,
//    value: value,
//    comp: comp,
//  );
//  if (found != -1) {
//    list.insert(at, found);
//    return true;
//  }
//  return false;
//}
