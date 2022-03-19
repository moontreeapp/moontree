import 'dart:math' as math;

import 'package:collection/src/iterable_extensions.dart';
import 'package:quiver/iterables.dart';

extension SumAList on Iterable {
  num sum() => fold(
      0,
      (previousValue, element) =>
          previousValue + (element is num ? element : 0));
  int sumInt({bool truncate = true}) =>
      truncate ? sum().toInt() : sum().round();
  double sumDouble() => sum().toDouble();
}

extension MinMaxOfAIteratableInt on Iterable<int> {
  int get max => reduce(math.max);
  int get min => reduce(math.min);
}

extension MinMaxOfAIteratableDouble on Iterable<double> {
  double get max => reduce(math.max);
  double get min => reduce(math.min);
}

extension EnumeratedIteratable on Iterable {
  Iterable<List> enumerated() =>
      zip([mapIndexed((index, element) => index).toList(), this]);
}
