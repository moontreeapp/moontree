// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MetadataTypeAdapter extends TypeAdapter<MetadataType> {
  @override
  final int typeId = 105;

  @override
  MetadataType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MetadataType.Unknown;
      case 1:
        return MetadataType.JsonString;
      case 2:
        return MetadataType.ImagePath;
      default:
        return MetadataType.Unknown;
    }
  }

  @override
  void write(BinaryWriter writer, MetadataType obj) {
    switch (obj) {
      case MetadataType.Unknown:
        writer.writeByte(0);
        break;
      case MetadataType.JsonString:
        writer.writeByte(1);
        break;
      case MetadataType.ImagePath:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetadataTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
