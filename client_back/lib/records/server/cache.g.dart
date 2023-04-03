// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedServerObjectAdapter extends TypeAdapter<CachedServerObject> {
  @override
  final int typeId = 200;

  @override
  CachedServerObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedServerObject(
      type: fields[0] as String,
      json: fields[1] as String,
      serverId: fields[2] as int?,
      walletId: fields[3] as String?,
      symbol: fields[4] as String?,
      chain: fields[5] as Chain?,
      net: fields[6] as Net?,
      txHash: fields[7] as String?,
      height: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, CachedServerObject obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.json)
      ..writeByte(2)
      ..write(obj.serverId)
      ..writeByte(3)
      ..write(obj.walletId)
      ..writeByte(4)
      ..write(obj.symbol)
      ..writeByte(5)
      ..write(obj.chain)
      ..writeByte(6)
      ..write(obj.net)
      ..writeByte(7)
      ..write(obj.txHash)
      ..writeByte(8)
      ..write(obj.height);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedServerObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
