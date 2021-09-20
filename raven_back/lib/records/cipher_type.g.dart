// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cipher_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CipherTypeAdapter extends TypeAdapter<CipherType> {
  @override
  final int typeId = 104;

  @override
  CipherType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CipherType.CipherNone;
      case 1:
        return CipherType.CipherAES;
      default:
        return CipherType.CipherNone;
    }
  }

  @override
  void write(BinaryWriter writer, CipherType obj) {
    switch (obj) {
      case CipherType.CipherNone:
        writer.writeByte(0);
        break;
      case CipherType.CipherAES:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CipherTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
