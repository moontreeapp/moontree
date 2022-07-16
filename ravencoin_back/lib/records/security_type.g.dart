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
        return SecurityType.Fiat;
      case 1:
        return SecurityType.Crypto;
      case 2:
        return SecurityType.RavenAsset;
      case 3:
        return SecurityType.RavenMaster;
      default:
        return SecurityType.Fiat;
    }
  }

  @override
  void write(BinaryWriter writer, SecurityType obj) {
    switch (obj) {
      case SecurityType.Fiat:
        writer.writeByte(0);
        break;
      case SecurityType.Crypto:
        writer.writeByte(1);
        break;
      case SecurityType.RavenAsset:
        writer.writeByte(2);
        break;
      case SecurityType.RavenMaster:
        writer.writeByte(3);
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
