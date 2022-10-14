// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_exposure.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NodeExposureAdapter extends TypeAdapter<NodeExposure> {
  @override
  final int typeId = 101;

  @override
  NodeExposure read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NodeExposure.internal;
      case 1:
        return NodeExposure.external;
      default:
        return NodeExposure.internal;
    }
  }

  @override
  void write(BinaryWriter writer, NodeExposure obj) {
    switch (obj) {
      case NodeExposure.internal:
        writer.writeByte(0);
        break;
      case NodeExposure.external:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeExposureAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
