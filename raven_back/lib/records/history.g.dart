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
      accountId: fields[0] as String,
      walletId: fields[1] as String,
      scripthash: fields[2] as String,
      height: fields[3] as int,
      hash: fields[4] as String,
      position: fields[5] as int,
      value: fields[6] as int,
      security: fields[7] as Security,
      note: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, History obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.accountId)
      ..writeByte(1)
      ..write(obj.walletId)
      ..writeByte(2)
      ..write(obj.scripthash)
      ..writeByte(3)
      ..write(obj.height)
      ..writeByte(4)
      ..write(obj.hash)
      ..writeByte(5)
      ..write(obj.position)
      ..writeByte(6)
      ..write(obj.value)
      ..writeByte(7)
      ..write(obj.security)
      ..writeByte(8)
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
