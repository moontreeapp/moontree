extension SumAList on Iterable {
  num sum() => fold(
      0,
      (previousValue, element) =>
          previousValue + (element is num ? element : 0));
  int sumInt({bool truncate = true}) =>
      truncate ? sum().toInt() : sum().round();
  double sumDouble() => sum().toDouble();
}

extension MinMaxOfAIteratable on Iterable {
  num max() => isNotEmpty ? reduce((v, e) => v > e ? v : e) : 0;
  num min() => isNotEmpty ? reduce((v, e) => v < e ? v : e) : 0;
}
