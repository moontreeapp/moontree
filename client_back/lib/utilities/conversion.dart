import 'dart:typed_data';
import 'package:wallet_utils/src/utilities/address.dart';
import 'package:convert/convert.dart';

Uint8List hash160FromHexString(String x) =>
    hash160(Uint8List.fromList(hex.decode(x)));
