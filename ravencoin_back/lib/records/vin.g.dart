// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vin.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VinAdapter extends TypeAdapter<Vin> {
  @override
  final int typeId = 6;

  @override
  Vin read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vin(
      transactionId: fields[0] as String,
      voutTransactionId: fields[1] as String,
      voutPosition: fields[2] as int,
      isCoinbase: fields[3] as bool,
      chain: fields[4] == null ? Chain.ravencoin : fields[4] as Chain,
      net: fields[5] == null ? Net.Main : fields[5] as Net,
    );
  }

  @override
  void write(BinaryWriter writer, Vin obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.transactionId)
      ..writeByte(1)
      ..write(obj.voutTransactionId)
      ..writeByte(2)
      ..write(obj.voutPosition)
      ..writeByte(3)
      ..write(obj.isCoinbase)
      ..writeByte(4)
      ..write(obj.chain)
      ..writeByte(5)
      ..write(obj.net);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VinAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
