List<int> toRange(int length, {int? start, int step = 1}) =>
    List<int>.generate(length, (i) {
      return i > 0 ? i + step : start ?? i + step;
    });

Map reverseMap(Map map) => {for (var e in map.entries) e.value: e.key};

Map mapMap(Map map, Map mapmap, {bool onKey = false}) => {
      for (var e in map.entries)
        e.key: mapmap[onKey ? e.key : e.value] ?? e.value
    };

bool any(List<bool> items) {
  for (var item in items) {
    if (item) {
      return true;
    }
  }
  return false;
}

bool all(List<bool> items) {
  for (var item in items) {
    if (!item) {
      return false;
    }
  }
  return true;
}

extension SumAList on List {
  num sum() => fold(0, (previousValue, element) => previousValue + element);
  int sumInt() => sum().toInt();
  double sumDouble() => sum().toDouble();
}
