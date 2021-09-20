List<int> toRange(int length, {int? start, int step = 1}) =>
    List<int>.generate(length, (i) {
      return i > 0 ? i + step : start ?? i + step;
    });

Map reverseMap(Map map) => {for (var e in map.entries) e.value: e.key};
