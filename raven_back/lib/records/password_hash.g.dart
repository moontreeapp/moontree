// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_hash.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PasswordHashAdapter extends TypeAdapter<PasswordHash> {
  @override
  final int typeId = 23;

  @override
  PasswordHash read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PasswordHash(
      passwordId: fields[0] as int,
      saltedHash: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PasswordHash obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.passwordId)
      ..writeByte(1)
      ..write(obj.saltedHash);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordHashAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
