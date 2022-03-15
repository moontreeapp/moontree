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
const List<int> RVN_q = [0x71];
const List<int> RVN_o = [0x6F];

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

Uint8List generateAssetCreateScript(Uint8List standardScript, String assetName,
    int amount, int divisibility, bool reissuable, Uint8List? ipfsData) {
  // standardScript is where the new asset is sent
  if (!isAssetNameGood(assetName)) {
    throw new ArgumentError('Invalid asset name');
  }
  if (amount < 0 || amount > 21000000000) {
    throw new ArgumentError('Invalid asset amount');
  }
  if (divisibility < 0 || divisibility > 8) {
    throw new ArgumentError('Invalid divisibility');
  }
  if (ipfsData?.length != null && ipfsData?.length != 34) {
    throw new ArgumentError('Invalid IPFS data');
  }

  final amountData = ByteData(8);
  amountData.setUint64(0, amount, Endian.little);

  final internal_builder = new BytesBuilder();
  internal_builder.add(RVN_rvn);
  internal_builder.add(RVN_q);
  internal_builder.addByte(assetName.length);
  internal_builder.add(utf8.encode(assetName));
  internal_builder.add(amountData.buffer.asUint8List());
  internal_builder.addByte(divisibility);
  internal_builder.addByte(reissuable ? 1 : 0);
  if (ipfsData != null) {
    internal_builder.addByte(1);
    internal_builder.add(ipfsData);
  } else {
    internal_builder.addByte(0);
  }

  // OP_PUSH  ( b'rvnt' | var_int (assetName) | sats | divisibility | reissuable | hasIPFS | ipfsData? )
  final internal_script = bscript.compile([internal_builder.takeBytes()]);

  internal_builder.add(standardScript);
  internal_builder.addByte(OPS['OP_RVN_ASSET']!);
  internal_builder.add(internal_script!);
  internal_builder.addByte(OPS['OP_DROP']!);

  return internal_builder.toBytes();
}

Uint8List generateAssetOwnershipScript(
    Uint8List standardScript, String assetName) {
  // standardScript is where the new asset is sent
  if (!isAssetNameGood(assetName)) {
    throw new ArgumentError('Invalid asset name');
  }

  final internal_builder = new BytesBuilder();
  internal_builder.add(RVN_rvn);
  internal_builder.add(RVN_o);
  internal_builder.addByte(assetName.length + 1);
  internal_builder.add(utf8.encode(assetName + '!'));

  // OP_PUSH  ( b'rvno' | var_int (assetName) )
  final internal_script = bscript.compile([internal_builder.takeBytes()]);

  internal_builder.add(standardScript);
  internal_builder.addByte(OPS['OP_RVN_ASSET']!);
  internal_builder.add(internal_script!);
  internal_builder.addByte(OPS['OP_DROP']!);

  return internal_builder.toBytes();
}
