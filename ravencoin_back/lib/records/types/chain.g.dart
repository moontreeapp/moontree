// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chain.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChainAdapter extends TypeAdapter<Chain> {
  @override
  final int typeId = 108;

  @override
  Chain read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Chain.none;
      case 1:
        return Chain.evrmore;
      case 2:
        return Chain.ravencoin;
      default:
        return Chain.none;
    }
  }

  @override
  void write(BinaryWriter writer, Chain obj) {
    switch (obj) {
      case Chain.none:
        writer.writeByte(0);
        break;
      case Chain.evrmore:
        writer.writeByte(1);
        break;
      case Chain.ravencoin:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChainAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
