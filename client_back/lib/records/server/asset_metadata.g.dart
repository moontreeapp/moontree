// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_metadata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssetMetadataRecordAdapter extends TypeAdapter<AssetMetadataRecord> {
  @override
  final int typeId = 201;

  @override
  AssetMetadataRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssetMetadataRecord(
      serverId: fields[0] as int?,
      voutId: fields[1] as int,
      verifierStringVoutId: fields[2] as int?,
      symbol: fields[3] as String,
      chain: fields[4] as Chain,
      net: fields[5] as Net,
      totalSupply: fields[6] as int,
      divisibility: fields[7] as int,
      reissuable: fields[8] as bool,
      frozen: fields[9] as bool,
      associatedData: fields[10] as ByteData,
    );
  }

  @override
  void write(BinaryWriter writer, AssetMetadataRecord obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.serverId)
      ..writeByte(1)
      ..write(obj.voutId)
      ..writeByte(2)
      ..write(obj.verifierStringVoutId)
      ..writeByte(3)
      ..write(obj.symbol)
      ..writeByte(4)
      ..write(obj.chain)
      ..writeByte(5)
      ..write(obj.net)
      ..writeByte(6)
      ..write(obj.totalSupply)
      ..writeByte(7)
      ..write(obj.divisibility)
      ..writeByte(8)
      ..write(obj.reissuable)
      ..writeByte(9)
      ..write(obj.frozen)
      ..writeByte(10)
      ..write(obj.associatedData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetMetadataRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
