/// example of asset with memo (message):
/// https://rvnt.cryptoscope.io/tx/?txid=aa093a7ac5e8cd1d47ec6354d6df134e7ebfd61e2f0d402e11e6cf7cb3f827bf

import 'dart:core';
import 'dart:typed_data';
import 'dart:convert';
import 'utils/script.dart' as bscript;
import 'utils/constants/op.dart';
import 'validate.dart';

const List<int> RVN_rvn = [0x72, 0x76, 0x6e];
const List<int> RVN_t = [0x74];

// standard_script should have no OP_PUSH
Uint8List generateAssetTransferScript(Uint8List standardScript,
    String assetName, int amount, Uint8List? ipfsData) {
  // ORIGINAL | OP_RVN_ASSET | OP_PUSH  ( b'rvnt' | var_int (assetName) | sats | ipfsData? ) | OP_DROP
  if (!isAssetNameGood(assetName)) {
    throw new ArgumentError('Invalid asset name');
  }
  if (amount < 0 || amount > 21000000000) {
    throw new ArgumentError('Invalid asset amount');
  }
  if (ipfsData?.length != null && ipfsData?.length != 34) {
    throw new ArgumentError('Invalid IPFS data');
  }

  final amountData = ByteData(8);
  amountData.setUint64(0, amount, Endian.little);

  final internal_builder = new BytesBuilder();
  internal_builder.add(RVN_rvn);
  internal_builder.add(RVN_t);
  internal_builder.addByte(assetName.length);
  internal_builder.add(utf8.encode(assetName));
  internal_builder.add(amountData.buffer.asUint8List());
  if (ipfsData != null) {
    internal_builder.add(ipfsData);
  }

  // OP_PUSH  ( b'rvnt' | var_int (assetName) | sats | ipfsData? )
  final internal_script = bscript.compile([internal_builder.takeBytes()]);

  internal_builder.add(standardScript);
  internal_builder.addByte(OPS['OP_RVN_ASSET']!);
  internal_builder.add(internal_script!);
  internal_builder.addByte(OPS['OP_DROP']!);

  return internal_builder.toBytes();
}
