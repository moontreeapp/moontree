List<int> toRange(int length, {int? start, int step = 1}) =>
    List<int>.generate(length, (i) {
      return i > 0 ? i + step : start ?? i + step;
    });
