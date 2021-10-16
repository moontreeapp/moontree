// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VoutAdapter extends TypeAdapter<Vout> {
  @override
  final int typeId = 7;

  @override
  Vout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vout(
      txId: fields[0] as String,
      value: fields[1] as int,
      position: fields[2] as int,
      security: fields[3] as Security,
    );
  }

  @override
  void write(BinaryWriter writer, Vout obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.txId)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.position)
      ..writeByte(3)
      ..write(obj.security);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
