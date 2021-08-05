// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BalanceAdapter extends TypeAdapter<Balance> {
  @override
  final int typeId = 3;

  @override
  Balance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Balance(
      confirmed: fields[0] as int,
      unconfirmed: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Balance obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.confirmed)
      ..writeByte(1)
      ..write(obj.unconfirmed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BalanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
