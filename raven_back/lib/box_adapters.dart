import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:sorted_list/sorted_list.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:ravencoin/ravencoin.dart';
import 'account.dart';
import 'network_params.dart';

class HDNodeAdapter extends TypeAdapter<HDNode> {
  @override
  final typeId = 6;

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

class HDWalletAdapter extends TypeAdapter<HDWallet> {
  @override
  final typeId = 5;

  @override
  HDWallet read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HDWallet.fromSeed(fields[0], network: fields[1]);
  }

  @override
  void write(BinaryWriter writer, HDWallet obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.seed)
      ..writeByte(1)
      ..write(obj.network);
  }
}

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

//enum NodeExposure { Internal, External }
class NodeExposureAdapter extends TypeAdapter<NodeExposure> {
  @override
  final typeId = 9;

  @override
  NodeExposure read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return fields[0];
  }

  @override
  void write(BinaryWriter writer, NodeExposure obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj);
  }
}

class ScripthashUnspentAdapter extends TypeAdapter<ScripthashUnspent> {
  @override
  final typeId = 10;

  @override
  ScripthashUnspent read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScripthashUnspent(
      scripthash: fields[0] as String,
      height: fields[1] as int,
      txHash: fields[2] as String,
      txPos: fields[3] as int,
      value: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ScripthashUnspent obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.scripthash)
      ..writeByte(1)
      ..write(obj.height)
      ..writeByte(2)
      ..write(obj.txHash)
      ..writeByte(3)
      ..write(obj.txPos)
      ..writeByte(4)
      ..write(obj.value);
  }
}

class ScripthashHistoryAdapter extends TypeAdapter<ScripthashHistory> {
  @override
  final typeId = 11;

  @override
  ScripthashHistory read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScripthashHistory(
      height: fields[0] as int,
      txHash: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ScripthashHistory obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.height)
      ..writeByte(1)
      ..write(obj.txHash);
  }
}

class ScripthashBalanceAdapter extends TypeAdapter<ScripthashBalance> {
  @override
  final typeId = 12;

  @override
  ScripthashBalance read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScripthashBalance(
      fields[0] as int,
      fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ScripthashBalance obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.confirmed)
      ..writeByte(1)
      ..write(obj.unconfirmed);
  }
}

class SortedListAdapter extends TypeAdapter<SortedList> {
  @override
  final typeId = 14;

  @override
  SortedList read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    var sortedList = SortedList<ScripthashUnspent>(
        (ScripthashUnspent a, ScripthashUnspent b) =>
            a.value.compareTo(b.value));
    sortedList.addAll(fields[0] as Iterable<ScripthashUnspent>);
    return sortedList;
  }

  @override
  void write(BinaryWriter writer, SortedList obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj);
  }
}
