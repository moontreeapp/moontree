// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SecurityTypeAdapter extends TypeAdapter<SecurityType> {
  @override
  final int typeId = 104;

  @override
  SecurityType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SecurityType.fiat;
      case 1:
        return SecurityType.coin;
      case 2:
        return SecurityType.asset;
      default:
        return SecurityType.fiat;
    }
  }

  @override
  void write(BinaryWriter writer, SecurityType obj) {
    switch (obj) {
      case SecurityType.fiat:
        writer.writeByte(0);
        break;
      case SecurityType.coin:
        writer.writeByte(1);
        break;
      case SecurityType.asset:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecurityTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
