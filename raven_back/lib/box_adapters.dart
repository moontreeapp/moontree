import 'dart:typed_data';
import 'package:bip32/bip32.dart' as bip32;
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:hive/hive.dart';
import 'package:raven/account.dart';
import 'package:raven/electrum_client.dart';
import 'package:raven/network_params.dart';

class CachedNodeAdapter extends TypeAdapter<CachedNode> {
  @override
  final typeId = 0;

  @override
  CachedNode read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedNode(
      fields[0] as HDNode,
      balance: fields[1] as ScriptHashBalance,
      unspent: fields[2] as List<ScriptHashUnspent>,
      history: fields[3] as List<ScriptHashHistory>,
    );
  }

  @override
  void write(BinaryWriter writer, CachedNode obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.node)
      ..writeByte(1)
      ..write(obj.balance)
      ..writeByte(2)
      ..write(obj.unspent)
      ..writeByte(3)
      ..write(obj.history);
  }
}

class HDNodeAdapter extends TypeAdapter<HDNode> {
  @override
  final typeId = 1;

  @override
  HDNode read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HDNode(
      fields[0] as NetworkParams,
      fields[1] as HDWallet,
      fields[2] as int,
      fields[3] as NodeExposure,
    );
  }

  @override
  void write(BinaryWriter writer, HDNode obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.params)
      ..writeByte(1)
      ..write(obj.wallet)
      ..writeByte(2)
      ..write(obj.index)
      ..writeByte(3)
      ..write(obj.exposure);
  }
}

class NetworkParamsAdapter extends TypeAdapter<NetworkParams> {
  @override
  final typeId = 2;

  @override
  NetworkParams read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NetworkParams(
      name: fields[0] as String,
      testnet: fields[1] as bool,
      network: fields[2] as NetworkType,
      derivationBase: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NetworkParams obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.testnet)
      ..writeByte(2)
      ..write(obj.network)
      ..writeByte(3)
      ..write(obj.derivationBase);
  }
}

class NetworkTypeAdapter extends TypeAdapter<NetworkType> {
  @override
  final typeId = 3;

  @override
  NetworkType read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NetworkType(
      messagePrefix: fields[0] as String,
      bech32: fields[1] as String,
      bip32: fields[2] as Bip32Type,
      pubKeyHash: fields[3] as int,
      scriptHash: fields[4] as int,
      wif: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, NetworkType obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.messagePrefix)
      ..writeByte(1)
      ..write(obj.bech32)
      ..writeByte(2)
      ..write(obj.bip32)
      ..writeByte(3)
      ..write(obj.pubKeyHash)
      ..writeByte(4)
      ..write(obj.scriptHash)
      ..writeByte(5)
      ..write(obj.wif);
  }
}

class Bip32TypeAdapter extends TypeAdapter<Bip32Type> {
  @override
  final typeId = 4;

  @override
  Bip32Type read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bip32Type(
      public: fields[0] as int,
      private: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Bip32Type obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.public)
      ..writeByte(1)
      ..write(obj.private);
  }
}

/* hidden attributes?
class HDWalletAdapter extends TypeAdapter<HDWallet> {
  @override
  final typeId = 5;

  @override
  HDWallet read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HDWallet(
      bip32: fields[0] as bip32.BIP32,
      p2pkh: fields[1] as P2PKH,
      seed: fields[2] as String,
      network: fields[3] as NetworkType,
    );
  }

  @override
  void write(BinaryWriter writer, HDWallet obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj._bip32)
      ..writeByte(1)
      ..write(obj._p2pkh)
      ..writeByte(2)
      ..write(obj.seed)
      ..writeByte(3)
      ..write(obj.network);
  }
}

class BIP32Adapter extends TypeAdapter<bip32.BIP32> {
  @override
  final typeId = 6;

  @override
  bip32.BIP32 read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return bip32.BIP32(
      fields [0] as Uint8List,
      fields [1] as Uint8List,
      fields [2] as Uint8List,
      fields [3] as int,
      index: fields [4] as int,
      network: fields [5] as NetworkType,
      parentFingerprint = 0x00000000: fields [6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, bip32.BIP32 obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj._d)
      ..writeByte(1)
      ..write(obj._Q)
      ..writeByte(2)
      ..write(obj.chainCode)
      ..writeByte(3)
      ..write(obj.depth)
      ..writeByte(4)
      ..write(obj.index)
      ..writeByte(5)
      ..write(obj.network)
      ..writeByte(6)
      ..write(obj.parentFingerprint);
  }
}
*/

class P2PKHAdapter extends TypeAdapter<P2PKH> {
  @override
  final typeId = 7;

  @override
  P2PKH read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return P2PKH(
      data: fields[0] as PaymentData,
      network: fields[1] as NetworkType,
    );
  }

  @override
  void write(BinaryWriter writer, P2PKH obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.data)
      ..writeByte(1)
      ..write(obj.network);
  }
}

class PaymentDataAdapter extends TypeAdapter<PaymentData> {
  @override
  final typeId = 8;

  @override
  PaymentData read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentData(
      address: fields[0] as String,
      hash: fields[1] as Uint8List,
      output: fields[2] as Uint8List,
      signature: fields[3] as Uint8List,
      pubkey: fields[4] as Uint8List,
      input: fields[5] as Uint8List,
      witness: fields[6] as List<Uint8List>,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentData obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.address)
      ..writeByte(1)
      ..write(obj.hash)
      ..writeByte(2)
      ..write(obj.output)
      ..writeByte(3)
      ..write(obj.signature)
      ..writeByte(4)
      ..write(obj.pubkey)
      ..writeByte(5)
      ..write(obj.input)
      ..writeByte(6)
      ..write(obj.witness);
  }
}
