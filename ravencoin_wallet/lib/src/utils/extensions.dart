import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';

extension StringBytesExtension on String {
  Uint8List get bytesUint8 => Uint8List.fromList(bytes);
  Uint8List get hexBytes => Uint8List.fromList(hex.decode(this));
  List<int> get bytes => utf8.encode(this);
}
