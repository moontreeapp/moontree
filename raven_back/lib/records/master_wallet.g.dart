// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'master_wallet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MasterWalletAdapter extends TypeAdapter<MasterWallet> {
  @override
  final int typeId = 1;

  @override
  MasterWallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MasterWallet(
      fields[0] as Uint8List,
      net: fields[1] as Net,
    );
  }

  @override
  void write(BinaryWriter writer, MasterWallet obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.encryptedSeed)
      ..writeByte(1)
      ..write(obj.net);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MasterWalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
