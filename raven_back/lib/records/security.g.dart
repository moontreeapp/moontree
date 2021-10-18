// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SecurityAdapter extends TypeAdapter<Security> {
  @override
  final int typeId = 21;

  @override
  Security read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Security(
      symbol: fields[0] as String,
      securityType: fields[1] as SecurityType,
      satsInCirculation: fields[2] as int?,
      precision: fields[3] as int?,
      reissuable: fields[4] as bool?,
      metadata: fields[5] as String?,
      txId: fields[6] as String?,
      position: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Security obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.securityType)
      ..writeByte(2)
      ..write(obj.satsInCirculation)
      ..writeByte(3)
      ..write(obj.precision)
      ..writeByte(4)
      ..write(obj.reissuable)
      ..writeByte(5)
      ..write(obj.metadata)
      ..writeByte(6)
      ..write(obj.txId)
      ..writeByte(7)
      ..write(obj.position);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecurityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
