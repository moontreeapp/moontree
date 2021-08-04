// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NetAdapter extends TypeAdapter<Net> {
  @override
  final int typeId = 5;

  @override
  Net read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Net.Main;
      case 1:
        return Net.Test;
      default:
        return Net.Main;
    }
  }

  @override
  void write(BinaryWriter writer, Net obj) {
    switch (obj) {
      case Net.Main:
        writer.writeByte(0);
        break;
      case Net.Test:
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
