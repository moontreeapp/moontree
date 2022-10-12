// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BalanceAdapter extends TypeAdapter<Balance> {
  @override
  final int typeId = 2;

  @override
  Balance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Balance(
      walletId: fields[0] as String,
      security: fields[1] as Security,
      confirmed: fields[2] as int,
      unconfirmed: fields[3] as int,
      chain: fields[4] == null ? Chain.ravencoin : fields[4] as Chain,
      net: fields[5] == null ? Net.Main : fields[5] as Net,
    );
  }

  @override
  void write(BinaryWriter writer, Balance obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.walletId)
      ..writeByte(1)
      ..write(obj.security)
      ..writeByte(2)
      ..write(obj.confirmed)
      ..writeByte(3)
      ..write(obj.unconfirmed)
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
      other is BalanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
