import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';

extension StringBytesExtension on String {
  Uint8List get bytes => Uint8List.fromList(codeUnits);
  Uint8List get hexBytes => Uint8List.fromList(hex.decode(this));
  List<int> get uft8Bytes => utf8.encode(this);
}
