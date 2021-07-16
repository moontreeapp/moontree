// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_stored.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountStoredAdapter extends TypeAdapter<AccountStored> {
  @override
  final int typeId = 13;

  @override
  AccountStored read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AccountStored(
      fields[0] as Uint8List,
      name: fields[2] as String,
    )
      ..params = fields[1] as NetworkParams?
      ..accountId = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, AccountStored obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.symmetricallyEncryptedSeed)
      ..writeByte(1)
      ..write(obj.params)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.accountId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountStoredAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
