// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imported_hd_wallet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImportedDerivedWalletAdapter extends TypeAdapter<ImportedDerivedWallet> {
  @override
  final int typeId = 7;

  @override
  ImportedDerivedWallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImportedDerivedWallet(
      fields[0] as Uint8List,
      net: fields[1] as Net,
    );
  }

  @override
  void write(BinaryWriter writer, ImportedDerivedWallet obj) {
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
      other is ImportedDerivedWalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
