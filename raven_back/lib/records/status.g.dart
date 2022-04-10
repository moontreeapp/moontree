// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatusAdapter extends TypeAdapter<Status> {
  @override
  final int typeId = 8;

  @override
  Status read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Status(
      linkId: fields[0] as String,
      statusType: fields[1] as StatusType,
      status: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Status obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.linkId)
      ..writeByte(1)
      ..write(obj.statusType)
      ..writeByte(2)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
