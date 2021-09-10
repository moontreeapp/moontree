// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryAdapter extends TypeAdapter<History> {
  @override
  final int typeId = 3;

  @override
  History read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return History(
      scripthash: fields[0] as String,
      height: fields[1] as int,
      hash: fields[2] as String,
      position: fields[3] as int,
      value: fields[4] as int,
      security: fields[5] as Security,
      memo: fields[6] as String,
      note: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, History obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.scripthash)
      ..writeByte(1)
      ..write(obj.height)
      ..writeByte(2)
      ..write(obj.hash)
      ..writeByte(3)
      ..write(obj.position)
      ..writeByte(4)
      ..write(obj.value)
      ..writeByte(5)
      ..write(obj.security)
      ..writeByte(6)
      ..write(obj.memo)
      ..writeByte(7)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
