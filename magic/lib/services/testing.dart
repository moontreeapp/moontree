import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/address.dart';

class Testing {
  static void test() {
    String address = "ETn6qeQb6vdmxdBUE77jetUK9e6cd9TCCC";
    try {
      Uint8List h160 = addressToH160(address);
      print('h160: ${hex.encode(h160)}');
      print(
          'backtoAddres: ${Blockchain.evrmoreMain.addressFromH160String(hex.encode(h160))}');
    } catch (e) {
      print('Error: $e');
    }
  }
}
