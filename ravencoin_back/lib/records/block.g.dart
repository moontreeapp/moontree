// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BlockAdapter extends TypeAdapter<Block> {
  @override
  final int typeId = 5;

  @override
  Block read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Block(
      height: fields[0] as int,
      chain: fields[1] == null ? Chain.ravencoin : fields[1] as Chain,
      net: fields[2] == null ? Net.Main : fields[2] as Net,
    );
  }

  @override
  void write(BinaryWriter writer, Block obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.height)
      ..writeByte(1)
      ..write(obj.chain)
      ..writeByte(2)
      ..write(obj.net);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
