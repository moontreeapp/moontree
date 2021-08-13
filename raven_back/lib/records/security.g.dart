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
    );
  }

  @override
  void write(BinaryWriter writer, Security obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.securityType);
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
