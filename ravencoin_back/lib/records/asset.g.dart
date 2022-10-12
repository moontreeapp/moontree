// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssetAdapter extends TypeAdapter<Asset> {
  @override
  final int typeId = 24;

  @override
  Asset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Asset(
      symbol: fields[0] as String,
      satsInCirculation: fields[1] as int,
      divisibility: fields[2] as int,
      reissuable: fields[3] as bool,
      metadata: fields[4] as String,
      transactionId: fields[5] as String,
      position: fields[6] as int,
      chain: fields[7] == null ? Chain.ravencoin : fields[7] as Chain,
      net: fields[8] == null ? Net.Main : fields[8] as Net,
    );
  }

  @override
  void write(BinaryWriter writer, Asset obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.satsInCirculation)
      ..writeByte(2)
      ..write(obj.divisibility)
      ..writeByte(3)
      ..write(obj.reissuable)
      ..writeByte(4)
      ..write(obj.metadata)
      ..writeByte(5)
      ..write(obj.transactionId)
      ..writeByte(6)
      ..write(obj.position)
      ..writeByte(7)
      ..write(obj.chain)
      ..writeByte(8)
      ..write(obj.net);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
