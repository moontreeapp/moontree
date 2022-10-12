// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unspent.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnspentAdapter extends TypeAdapter<Unspent> {
  @override
  final int typeId = 9;

  @override
  Unspent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Unspent(
      walletId: fields[0] as String,
      addressId: fields[1] as String,
      transactionId: fields[2] as String,
      position: fields[3] as int,
      height: fields[4] as int,
      value: fields[5] as int,
      symbol: fields[6] as String,
      chain: fields[7] == null ? Chain.ravencoin : fields[7] as Chain,
      net: fields[8] == null ? Net.Test : fields[8] as Net,
    );
  }

  @override
  void write(BinaryWriter writer, Unspent obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.walletId)
      ..writeByte(1)
      ..write(obj.addressId)
      ..writeByte(2)
      ..write(obj.transactionId)
      ..writeByte(3)
      ..write(obj.position)
      ..writeByte(4)
      ..write(obj.height)
      ..writeByte(5)
      ..write(obj.value)
      ..writeByte(6)
      ..write(obj.symbol)
      ..writeByte(7)
      ..write(obj.chain)
      ..writeByte(8)
      ..write(obj.net);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnspentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
