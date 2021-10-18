// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VoutAdapter extends TypeAdapter<Vout> {
  @override
  final int typeId = 7;

  @override
  Vout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vout(
      txId: fields[0] as String,
      value: fields[1] as int,
      position: fields[2] as int,
      securityId: fields[3] as String,
      type: fields[5] as String,
      address: fields[6] as String,
      additionalAddresses: (fields[9] as List?)?.cast<String>(),
      memo: fields[4] as String,
      asset: fields[7] as String?,
      amount: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Vout obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.txId)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.position)
      ..writeByte(3)
      ..write(obj.securityId)
      ..writeByte(4)
      ..write(obj.memo)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.address)
      ..writeByte(7)
      ..write(obj.asset)
      ..writeByte(8)
      ..write(obj.amount)
      ..writeByte(9)
      ..write(obj.additionalAddresses);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
