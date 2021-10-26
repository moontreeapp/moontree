import 'dart:typed_data';

Uint8List getBytes(String key) => Uint8List.fromList(key.codeUnits);
