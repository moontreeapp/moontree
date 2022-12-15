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
    final int numOfFields = reader.readByte();
    final Map<int, dynamic> fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Address(
      scripthash: fields[0] as String,
      address: fields[1] as String,
      walletId: fields[2] as String,
      hdIndex: fields[3] as int,
      exposure: fields[4] as NodeExposure,
      net: fields[5] as Net,
      chain: fields[6] == null ? Chain.ravencoin : fields[6] as Chain,
    );
  }

  @override
  void write(BinaryWriter writer, Address obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.scripthash)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.walletId)
      ..writeByte(3)
      ..write(obj.hdIndex)
      ..writeByte(4)
      ..write(obj.exposure)
      ..writeByte(5)
      ..write(obj.net)
      ..writeByte(6)
      ..write(obj.chain);
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
