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
      walletId: fields[0] as String,
      encryptedWIF: fields[3] as String,
      cipherUpdate: fields[1] as CipherUpdate,
    );
  }

  @override
  void write(BinaryWriter writer, SingleWallet obj) {
    writer
      ..writeByte(3)
      ..writeByte(3)
      ..write(obj.encryptedWIF)
      ..writeByte(0)
      ..write(obj.walletId)
      ..writeByte(1)
      ..write(obj.cipherUpdate);
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
