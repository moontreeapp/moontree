// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SingleWalletAdapter extends TypeAdapter<SingleWallet> {
  @override
  final int typeId = 10;

  @override
  SingleWallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SingleWallet(
      id: fields[0] as String,
      encryptedWIF: fields[7] as String,
      cipherUpdate: fields[1] as CipherUpdate,
      skipHistory: fields[4] == null ? false : fields[4] as bool,
      name: fields[2] as String?,
    )..backedUp = fields[3] as bool;
  }

  @override
  void write(BinaryWriter writer, SingleWallet obj) {
    writer
      ..writeByte(6)
      ..writeByte(7)
      ..write(obj.encryptedWIF)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cipherUpdate)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.backedUp)
      ..writeByte(4)
      ..write(obj.skipHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SingleWalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
