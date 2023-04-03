// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddressAdapter extends TypeAdapter<Address> {
  @override
  final int typeId = 1;

  @override
  Address read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Address(
      scripthash: fields[0] as String,
      pubkey: fields[1] as String,
      walletId: fields[2] as String,
      exposure: fields[4] as NodeExposure,
      index: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Address obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.scripthash)
      ..writeByte(1)
      ..write(obj.pubkey)
      ..writeByte(2)
      ..write(obj.walletId)
      ..writeByte(3)
      ..write(obj.index)
      ..writeByte(4)
      ..write(obj.exposure);
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
