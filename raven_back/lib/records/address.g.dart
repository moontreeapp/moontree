// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddressAdapter extends TypeAdapter<Address> {
  @override
  final int typeId = 2;

  @override
  Address read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Address(
      scripthash: fields[0] as String,
      address: fields[1] as String,
      walletId: fields[2] as String,
      accountId: fields[3] as String,
      hdIndex: fields[4] as int,
      exposure: fields[5] as NodeExposure,
      net: fields[6] as Net,
      balance: fields[7] as Balance?,
    );
  }

  @override
  void write(BinaryWriter writer, Address obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.scripthash)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.walletId)
      ..writeByte(3)
      ..write(obj.accountId)
      ..writeByte(4)
      ..write(obj.hdIndex)
      ..writeByte(5)
      ..write(obj.exposure)
      ..writeByte(6)
      ..write(obj.net)
      ..writeByte(7)
      ..write(obj.balance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
