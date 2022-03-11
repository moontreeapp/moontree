import 'dart:typed_data';
import 'package:convert/convert.dart';

extension SumAList on List {
  num sum() => fold(
      0,
      (previousValue, element) =>
          previousValue + (element is num ? element : 0));
  int sumInt({bool truncate = true}) =>
      truncate ? sum().toInt() : sum().round();
  double sumDouble() => sum().toDouble();
}

extension StringExtension on Uint8List {
  String get toEncodedString => hex.encode(this);
}
