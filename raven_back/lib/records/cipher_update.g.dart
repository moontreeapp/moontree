// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cipher_update.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CipherUpdateAdapter extends TypeAdapter<CipherUpdate> {
  @override
  final int typeId = 22;

  @override
  CipherUpdate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CipherUpdate(
      fields[0] as CipherType,
      passwordId: fields[1] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, CipherUpdate obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.cipherType)
      ..writeByte(1)
      ..write(obj.passwordId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CipherUpdateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
