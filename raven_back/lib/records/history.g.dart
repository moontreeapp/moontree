// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryAdapter extends TypeAdapter<History> {
  @override
  final int typeId = 5;

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
      txHash: fields[4] as String,
      txPos: fields[5] as int,
      value: fields[6] as int,
      security: fields[7] as Security,
    );
  }

  @override
  void write(BinaryWriter writer, History obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.accountId)
      ..writeByte(1)
      ..write(obj.walletId)
      ..writeByte(2)
      ..write(obj.scripthash)
      ..writeByte(3)
      ..write(obj.height)
      ..writeByte(4)
      ..write(obj.txHash)
      ..writeByte(5)
      ..write(obj.txPos)
      ..writeByte(6)
      ..write(obj.value)
      ..writeByte(7)
      ..write(obj.security);
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
