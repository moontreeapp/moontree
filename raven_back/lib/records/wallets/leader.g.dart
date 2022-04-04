// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leader.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeaderWalletAdapter extends TypeAdapter<LeaderWallet> {
  @override
  final int typeId = 11;

  @override
  LeaderWallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LeaderWallet(
      id: fields[0] as String,
      encryptedEntropy: fields[7] as String,
      cipherUpdate: fields[1] as CipherUpdate,
      name: fields[2] as String?,
    )
      ..highestUsedExternalIndex = fields[3] as int
      ..highestSavedExternalIndex = fields[4] as int
      ..highestUsedInternalIndex = fields[5] as int
      ..highestSavedInternalIndex = fields[6] as int;
  }

  @override
  void write(BinaryWriter writer, LeaderWallet obj) {
    writer
      ..writeByte(8)
      ..writeByte(7)
      ..write(obj.encryptedEntropy)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cipherUpdate)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.highestUsedExternalIndex)
      ..writeByte(4)
      ..write(obj.highestSavedExternalIndex)
      ..writeByte(5)
      ..write(obj.highestUsedInternalIndex)
      ..writeByte(6)
      ..write(obj.highestSavedInternalIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderWalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
