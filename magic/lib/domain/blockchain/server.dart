/* blockchain utils the server uses, we can use as well. */
import 'dart:typed_data';
import 'package:bip32/bip32.dart';
import 'package:bs58/bs58.dart';
import 'package:convert/convert.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:tuple/tuple.dart';

const coin = 100000000;
const addressGap = 20;

Uint8List byteDataToUint8List(ByteData byteData) {
  return byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
}

Uint8List h160FromXPubForAddress(String xpub, int index) {
  final hmacNode = BIP32.fromBase58(xpub);
  return hash160(compressPublicKey(hmacNode.derive(index).publicKey));
}

ByteData h160FromXPubServerWay(String xpub, int index) {
  final hmacNode = BIP32.fromBase58(xpub);
  return hash160(compressPublicKey(hmacNode.derive(index).publicKey))
      .buffer
      .asByteData(); // convert to address...
}

Uint8List compressPublicKey(Uint8List x) {
  if (x.isEmpty) {
    throw Exception('Empty byte array');
  }
  if (x[0] == 0x04) {
    int prefix = ((x[64] & 1) != 0) ? 0x03 : 0x02;
    return Uint8List.fromList([prefix, ...x.sublist(1, 33)]);
  } else if (x[0] == 0x03 || x[0] == 0x02) {
    return x;
  }
  throw Exception('Invalid public key format');
}

Uint8List hash160(Uint8List x) {
  return RIPEMD160Digest().process(SHA256Digest().process(x));
}

String h160ToAddress(Uint8List h160, int addrType) {
  if (h160.length != 0x14) {
    throw Exception('Invalid h160 length');
  }
  List<int> x = [];
  x.add(addrType);
  x.addAll(h160);
  x.addAll(doubleSHA256(Uint8List.fromList(x)).sublist(0, 4));
  return base58.encode(Uint8List.fromList(x));
}

class TypedH160 {
  final int type;
  final Uint8List h160;

  const TypedH160(this.type, this.h160);
}

// (OPCODE, LAST_POSITION, PUSHED_DATA)
List<Tuple3<int, int, Uint8List>> getOpCodes(Uint8List data, [offset = 0]) {
  final ops = <Tuple3<int, int, Uint8List>>[];
  int ptr = offset;

  while (ptr < data.length) {
    final op = data[ptr];
    var opTuple = Tuple3(op, ptr, Uint8List.fromList([]));
    ptr += 1;

    if (op <= 0x4e) {
      // These are OP_PUSHes
      int len;
      int lenSize;
      try {
        if (op < 0x4c) {
          len = op;
          lenSize = 0;
        } else if (op == 0x4c) {
          len = data[ptr];
          lenSize = 1;
        } else if (op == 0x4d) {
          len = data
              .sublist(ptr, ptr + 2)
              .buffer
              .asByteData()
              .getUint16(0, Endian.little);
          lenSize = 2;
        } else {
          len = data
              .sublist(ptr, ptr + 4)
              .buffer
              .asByteData()
              .getUint32(0, Endian.little);
          lenSize = 4;
        }

        ptr += lenSize;

        opTuple = Tuple3(op, ptr + len, data.sublist(ptr, ptr + len));
      } on RangeError {
        opTuple = Tuple3(-1, data.length - 1, data.sublist(ptr));
        ops.add(opTuple);
        break;
      }
      ptr += len;
    }
    ops.add(opTuple);
  }

  return ops;
}

String writeOpPushHex(int length) {
  if (length < 0x4c) {
    return hex.encode([length]);
  } else if (length < 0xff) {
    return '4c${hex.encode([length])}';
  } else if (length < 0xffff) {
    return '4d${hex.encode(Uint8List(2)..buffer.asByteData().setUint16(0, length, Endian.little))}';
  } else {
    return '4e${hex.encode(Uint8List(4)..buffer.asByteData().setUint32(0, length, Endian.little))}';
  }
}

// This returns a var int and how long it was
Tuple2<int, int> readVarInt(Uint8List data, [offset = 0]) {
  if (data[offset] < 0xfd) {
    return Tuple2(1, data[offset]);
  } else if (data[offset] == 0xfd) {
    return Tuple2(3,
        data.sublist(offset).buffer.asByteData().getUint16(1, Endian.little));
  } else if (data[offset] == 0xfe) {
    return Tuple2(5,
        data.sublist(offset).buffer.asByteData().getUint32(1, Endian.little));
  } else {
    return Tuple2(9,
        data.sublist(offset).buffer.asByteData().getUint64(1, Endian.little));
  }
}

String writeVarIntHex(int length) {
  if (length < 0xfd) {
    return hex.encode([length]);
  } else if (length <= 0xffff) {
    return 'fd${hex.encode(Uint8List(2)..buffer.asByteData().setUint16(0, length, Endian.little))}';
  } else if (length <= 0xffffffff) {
    return 'fe${hex.encode(Uint8List(4)..buffer.asByteData().setUint32(0, length, Endian.little))}';
  } else {
    return 'ff${hex.encode(Uint8List(8)..buffer.asByteData().setUint64(0, length, Endian.little))}';
  }
}

Uint8List doubleSHA256(Uint8List data) {
  final digest1 = SHA256Digest();
  final iter1 = digest1.process(data);
  final digest2 = SHA256Digest();
  return digest2.process(iter1);
}

String hashDecode(Uint8List rawHash) {
  return hex.encode(List.from(rawHash.reversed));
}

enum VoutDataType {
  h160,
  assetAmount,
  assetMetadata,
  assetMemo,
  assetVerifier,
  h160Freeze,
  globalFreeze,
  h160Qualification,
  opReturn,
}

abstract class VoutData {
  final VoutDataType type;
  const VoutData(this.type);
}

class OPReturnVoutData extends VoutData {
  final Uint8List opReturn;
  const OPReturnVoutData(this.opReturn) : super(VoutDataType.opReturn);

  @override
  String toString() {
    return 'OP_RETURN(${hex.encode(opReturn)})';
  }
}

abstract class AssetTagData extends VoutData {
  const AssetTagData(VoutDataType type) : super(type);
}

class H160Freeze extends AssetTagData {
  final Uint8List h160;
  final String asset;
  final bool isFrozen;
  const H160Freeze(this.h160, this.asset, this.isFrozen)
      : super(VoutDataType.h160Freeze);

  @override
  String toString() {
    return '$asset ${isFrozen ? "froze" : "unfroze"} ${h160ToAddress(h160, 111)}';
  }
}

class H160Qualification extends AssetTagData {
  final Uint8List h160;
  final String asset;
  final bool isQualified;
  const H160Qualification(this.h160, this.asset, this.isQualified)
      : super(VoutDataType.h160Qualification);

  @override
  String toString() {
    return '$asset ${isQualified ? "qualified" : "unqualified"} ${h160ToAddress(h160, 111)}';
  }
}

class Verifier extends AssetTagData {
  final String verifierString;
  const Verifier(this.verifierString) : super(VoutDataType.assetVerifier);

  @override
  String toString() {
    return 'Verifier: $verifierString';
  }
}

class GlobalFreeze extends AssetTagData {
  final String asset;
  final bool isFrozen;
  const GlobalFreeze(this.asset, this.isFrozen)
      : super(VoutDataType.globalFreeze);

  @override
  String toString() {
    return '$asset ${isFrozen ? "froze" : "unfroze"} globally';
  }
}

abstract class AssetData extends VoutData {
  const AssetData(VoutDataType type) : super(type);
}

class AssetAmount extends AssetData {
  final String asset;
  final int sats;
  const AssetAmount(this.asset, this.sats) : super(VoutDataType.assetAmount);

  @override
  String toString() {
    return 'Asset amount: $asset ($sats)';
  }
}

enum RawAssetMetadataType { ownership, create, reissue }

class RawAssetMetadata extends AssetData {
  final String asset;
  final int divisibility;
  final bool reissuable;
  final Uint8List? associatedData;
  final int addedSupply;
  final RawAssetMetadataType metadataType;

  const RawAssetMetadata(this.asset, this.divisibility, this.reissuable,
      this.associatedData, this.addedSupply, this.metadataType)
      : super(VoutDataType.assetMetadata);

  @override
  String toString() {
    return 'Asset data: $asset ($divisibility, $reissuable, ${associatedData == null ? "none" : base58.encode(associatedData!)})';
  }
}

class AssetMemo extends AssetData {
  final Uint8List memo;
  final int? timestamp;
  const AssetMemo(this.memo, [this.timestamp]) : super(VoutDataType.assetMemo);

  @override
  String toString() {
    return 'Asset memo: ${base58.encode(memo)} ($timestamp)';
  }
}
