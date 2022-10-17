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
        return MetadataType.unknown;
      case 1:
        return MetadataType.jsonString;
      case 2:
        return MetadataType.imagePath;
      default:
        return MetadataType.unknown;
    }
  }

  @override
  void write(BinaryWriter writer, MetadataType obj) {
    switch (obj) {
      case MetadataType.unknown:
        writer.writeByte(0);
        break;
      case MetadataType.jsonString:
        writer.writeByte(1);
        break;
      case MetadataType.imagePath:
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
