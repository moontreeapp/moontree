// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NetAdapter extends TypeAdapter<Net> {
  @override
  final int typeId = 100;

  @override
  Net read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Net.main;
      case 1:
        return Net.test;
      default:
        return Net.main;
    }
  }

  @override
  void write(BinaryWriter writer, Net obj) {
    switch (obj) {
      case Net.main:
        writer.writeByte(0);
        break;
      case Net.test:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
