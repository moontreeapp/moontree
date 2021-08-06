// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balances.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BalancesAdapter extends TypeAdapter<Balances> {
  @override
  final int typeId = 4;

  @override
  Balances read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Balances(
      balances: (fields[0] as Map).cast<String, Balance>(),
    );
  }

  @override
  void write(BinaryWriter writer, Balances obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.balances);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BalancesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
