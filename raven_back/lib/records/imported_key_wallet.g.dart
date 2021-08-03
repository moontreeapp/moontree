// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imported_key_wallet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImportedPrivateKeyWalletAdapter
    extends TypeAdapter<ImportedPrivateKeyWallet> {
  @override
  final int typeId = 8;

  @override
  ImportedPrivateKeyWallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImportedPrivateKeyWallet(
      fields[0] as Uint8List,
      net: fields[1] as Net,
    );
  }

  @override
  void write(BinaryWriter writer, ImportedPrivateKeyWallet obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.encryptedPrivateKey)
      ..writeByte(1)
      ..write(obj.net);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportedPrivateKeyWalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
