import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';

extension StringExtension on Uint8List {
  String get toEncodedString => hex.encode(this);
}

extension RandomChoiceExtension on List {
  dynamic get randomChoice => this[Random().nextInt(length)];
}
