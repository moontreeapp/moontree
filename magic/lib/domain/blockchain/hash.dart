//import 'dart:convert';
import 'dart:typed_data';

import 'package:moontree_utils/extensions/bytedata.dart';

String byteHashToString(ByteData hash) {
  return hash.toHex();
  // Convert ByteData to Uint8List
  //Uint8List bytes = hash.buffer.asUint8List();
  //// Convert Uint8List to String
  //return utf8.decode(bytes);
}
