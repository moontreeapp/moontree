/// example of asset with memo (message):
/// https://rvn${res.settings.mainnet ? '' : 't'}.cryptoscope.io/tx/?txid=aa093a7ac5e8cd1d47ec6354d6df134e7ebfd61e2f0d402e11e6cf7cb3f827bf

import 'dart:core';
import 'dart:typed_data';
import 'dart:convert';
import 'utils/script.dart' as bscript;
import 'utils/constants/op.dart';
import 'validate.dart';

const List<int> RVN_rvn = [0x72, 0x76, 0x6e];
const int RVN_t = 0x74;
const int RVN_q = 0x71;
const int RVN_o = 0x6F;
const int RVN_r = 0x72;

// standard_script should have no OP_PUSH
Uint8List generateAssetTransferScript(
    Uint8List standardScript, String assetName, int amount,
    {Uint8List? ipfsData, int? expireEpoch}) {
  // ORIGINAL | OP_RVN_ASSET | OP_PUSH  ( b'rvnt' | var_int (assetName) | sats | ipfsData? ) | OP_DROP
  if (!isAssetNameGood(assetName)) {
    throw new ArgumentError('Invalid asset name');
  }
  if (amount < 0 || amount > 21000000000 * 100000000) {
    throw new ArgumentError('Invalid asset amount');
  }
  if (ipfsData?.length != null && ipfsData?.length != 34) {
    throw new ArgumentError('Invalid IPFS data');
  }
  if (expireEpoch != null && expireEpoch <= 0) {
    throw new ArgumentError('Invalid expire time');
  }

  final amountData = ByteData(8);
  amountData.setUint64(0, amount, Endian.little);

  final internal_builder = new BytesBuilder();
  internal_builder.add(RVN_rvn);
  internal_builder.addByte(RVN_t);
  internal_builder.addByte(assetName.length);
  internal_builder.add(utf8.encode(assetName));
  internal_builder.add(amountData.buffer.asUint8List());
  if (ipfsData != null) {
    internal_builder.add(ipfsData);
  }
  if (expireEpoch != null) {
    amountData.setUint64(0, expireEpoch, Endian.little);
    internal_builder.add(amountData.buffer.asUint8List());
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
  if (amount < 0 || amount > 21000000000 * 100000000) {
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
  internal_builder.addByte(RVN_q);
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

// assetName must not including the ! only the actual asset name.
Uint8List generateAssetOwnershipScript(
    Uint8List standardScript, String assetName) {
  // standardScript is where the new asset is sent
  if (!isAssetNameGood(assetName)) {
    throw new ArgumentError('Invalid asset name');
  }

  final internal_builder = new BytesBuilder();
  internal_builder.add(RVN_rvn);
  internal_builder.addByte(RVN_o);
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

Uint8List generateAssetReissueScript(
    Uint8List standardScript,
    String assetName,
    int current_amount,
    int amount_to_add,
    int old_divisibility,
    int divisibility,
    bool reissuable,
    Uint8List? ipfsData) {
  // standardScript is where the new assets created (if any) are sent
  if (!isAssetNameGood(assetName)) {
    throw new ArgumentError('Invalid asset name');
  }
  if ((current_amount + amount_to_add) < 0 ||
      (current_amount + amount_to_add) > 21000000000 * 100000000) {
    throw new ArgumentError('Invalid asset amount');
  }
  if (divisibility < 0 || divisibility > 8) {
    throw new ArgumentError('Invalid divisibility');
  }
  if (divisibility < old_divisibility) {
    throw new ArgumentError(
        'New divisibility cannot be lower than old divisibility');
  }
  if (ipfsData?.length != null && ipfsData?.length != 34) {
    throw new ArgumentError('Invalid IPFS data');
  }

  final amountData = ByteData(8);
  amountData.setUint64(0, amount_to_add, Endian.little);

  final internal_builder = new BytesBuilder();
  internal_builder.add(RVN_rvn);
  internal_builder.addByte(RVN_r);
  internal_builder.addByte(assetName.length);
  internal_builder.add(utf8.encode(assetName));
  internal_builder.add(amountData.buffer.asUint8List());
  internal_builder
      .addByte(divisibility == old_divisibility ? 0xff : divisibility);
  internal_builder.addByte(reissuable ? 1 : 0);
  // There is no "hasIPFS" boolean in asset reissuances. Do not get confused with "is reissuable?"
  if (ipfsData != null) {
    internal_builder.add(ipfsData);
  }

  // OP_PUSH  ( b'rvnr' | var_int (assetName) | sats | divisibility | reissuable | ipfsData? )
  final internal_script = bscript.compile([internal_builder.takeBytes()]);

  internal_builder.add(standardScript);
  internal_builder.addByte(OPS['OP_RVN_ASSET']!);
  internal_builder.add(internal_script!);
  internal_builder.addByte(OPS['OP_DROP']!);

  return internal_builder.toBytes();
}

// Tag true:
//  Restricted assets: banned
//  Qualifier assets: qualified
// Tag false:
//  Restricted assets: allowed
//  Qualifier assets: not qualified

Uint8List generateNullQualifierTag(String asset, Uint8List h160, bool tag) {
  if (h160.length != 0x14) {
    throw new ArgumentError('Invalid h160 length');
  }
  if (!asset.contains(RegExp(r'^(\$|#).+$'))) {
    throw new ArgumentError(
        'Asset must be a restricted asset, qualifier, or sub qualifier');
  }

  final internal_builder = new BytesBuilder();

  internal_builder.addByte(asset.length);
  internal_builder.add(utf8.encode(asset));
  internal_builder.addByte(tag ? 1 : 0);

  return bscript
      .compile([OPS['OP_RVN_ASSET'], h160, internal_builder.toBytes()])!;
}

Uint8List generateNullVerifierTag(String verifier_string) {
  final internal_script = bscript.compile([utf8.encode(verifier_string)]);
  return bscript.compile([OPS['OP_RVN_ASSET'], 0x50, internal_script])!;
}

Uint8List generateNullGlobalFreezeTag(String asset, bool flag) {
  if (!asset.contains(RegExp(r'^\$.+$'))) {
    throw new ArgumentError('Asset must be a restricted asset');
  }
  final internal_script = bscript.compile([utf8.encode(asset), flag ? 1 : 0]);
  return bscript.compile([OPS['OP_RVN_ASSET'], 0x50, 0x50, internal_script])!;
}
