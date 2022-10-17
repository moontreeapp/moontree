// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatusTypeAdapter extends TypeAdapter<StatusType> {
  @override
  final int typeId = 107;

  @override
  StatusType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StatusType.address;
      case 1:
        return StatusType.asset;
      case 2:
        return StatusType.header;
      default:
        return StatusType.address;
    }
  }

  @override
  void write(BinaryWriter writer, StatusType obj) {
    switch (obj) {
      case StatusType.address:
        writer.writeByte(0);
        break;
      case StatusType.asset:
        writer.writeByte(1);
        break;
      case StatusType.header:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
