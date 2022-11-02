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
      position: fields[1] as int,
      type: fields[2] as String,
      rvnValue: fields[3] as int,
      assetValue: fields[4] as int?,
      lockingScript: fields[5] as String?,
      memo: fields[6] as String?,
      assetMemo: fields[7] as String?,
      assetSecurityId: fields[8] as String?,
      toAddress: fields[9] as String?,
      additionalAddresses: (fields[10] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Vout obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.transactionId)
      ..writeByte(1)
      ..write(obj.position)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.rvnValue)
      ..writeByte(4)
      ..write(obj.assetValue)
      ..writeByte(5)
      ..write(obj.lockingScript)
      ..writeByte(6)
      ..write(obj.memo)
      ..writeByte(7)
      ..write(obj.assetMemo)
      ..writeByte(8)
      ..write(obj.assetSecurityId)
      ..writeByte(9)
      ..write(obj.toAddress)
      ..writeByte(10)
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
