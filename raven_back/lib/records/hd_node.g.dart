// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hd_node.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HDNodeAdapter extends TypeAdapter<HDNode> {
  @override
  final int typeId = 6;

  @override
  HDNode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HDNode(
      fields[0] as int,
      fields[1] as Uint8List,
      networkWif: fields[2] as int,
      exposure: fields[3] as NodeExposure,
    );
  }

  @override
  void write(BinaryWriter writer, HDNode obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.index)
      ..writeByte(1)
      ..write(obj.seed)
      ..writeByte(2)
      ..write(obj.networkWif)
      ..writeByte(3)
      ..write(obj.exposure);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HDNodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
