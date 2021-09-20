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
      walletId: fields[0] as String,
      accountId: fields[1] as String,
      encryptedEntropy: fields[3] as String,
      cipherUpdate: fields[2] as CipherUpdate,
    );
  }

  @override
  void write(BinaryWriter writer, LeaderWallet obj) {
    writer
      ..writeByte(4)
      ..writeByte(3)
      ..write(obj.encryptedEntropy)
      ..writeByte(0)
      ..write(obj.walletId)
      ..writeByte(1)
      ..write(obj.accountId)
      ..writeByte(2)
      ..write(obj.cipherUpdate);
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
