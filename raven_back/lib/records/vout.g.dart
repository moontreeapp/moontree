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
      transactionId: fields[0] as String,
      rvnValue: fields[1] as int,
      position: fields[2] as int,
      memo: fields[3] as String,
      assetMemo: fields[4] as String,
      type: fields[5] as String,
      toAddress: fields[6] as String?,
      assetSecurityId: fields[7] as String?,
      assetValue: fields[8] as int?,
      additionalAddresses: (fields[9] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Vout obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.transactionId)
      ..writeByte(1)
      ..write(obj.rvnValue)
      ..writeByte(2)
      ..write(obj.position)
      ..writeByte(3)
      ..write(obj.memo)
      ..writeByte(4)
      ..write(obj.assetMemo)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.toAddress)
      ..writeByte(7)
      ..write(obj.assetSecurityId)
      ..writeByte(8)
      ..write(obj.assetValue)
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
