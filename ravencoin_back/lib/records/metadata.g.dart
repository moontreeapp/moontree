// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MetadataAdapter extends TypeAdapter<Metadata> {
  @override
  final int typeId = 25;

  @override
  Metadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Metadata(
      symbol: fields[0] as String,
      metadata: fields[1] as String,
      data: fields[2] as String?,
      kind: fields[3] as MetadataType,
      parent: fields[4] as String?,
      logo: fields[5] as bool,
      chain: fields[6] == null ? Chain.ravencoin : fields[6] as Chain,
      net: fields[7] == null ? Net.main : fields[7] as Net,
    );
  }

  @override
  void write(BinaryWriter writer, Metadata obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.metadata)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.kind)
      ..writeByte(4)
      ..write(obj.parent)
      ..writeByte(5)
      ..write(obj.logo)
      ..writeByte(6)
      ..write(obj.chain)
      ..writeByte(7)
      ..write(obj.net);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
