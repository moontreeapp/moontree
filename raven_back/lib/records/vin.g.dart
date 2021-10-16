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
      txId: fields[0] as String,
      voutTxId: fields[1] as String,
      voutPosition: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Vin obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.txId)
      ..writeByte(1)
      ..write(obj.voutTxId)
      ..writeByte(2)
      ..write(obj.voutPosition);
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
