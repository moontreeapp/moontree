// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_name.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingNameAdapter extends TypeAdapter<SettingName> {
  @override
  final int typeId = 102;

  @override
  SettingName read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SettingName.Electrum_Net;
      case 1:
        return SettingName.Electrum_Domain;
      case 2:
        return SettingName.Electrum_Port;
      case 3:
        return SettingName.Electrum_DomainTest;
      case 4:
        return SettingName.Electrum_PortTest;
      case 5:
        return SettingName.Wallet_Current;
      case 6:
        return SettingName.Wallet_Preferred;
      case 7:
        return SettingName.Local_Path;
      case 8:
        return SettingName.User_Name;
      case 9:
        return SettingName.Send_Immediate;
      case 10:
        return SettingName.Lockout_Milliseconds;
      default:
        return SettingName.Electrum_Net;
    }
  }

  @override
  void write(BinaryWriter writer, SettingName obj) {
    switch (obj) {
      case SettingName.Electrum_Net:
        writer.writeByte(0);
        break;
      case SettingName.Electrum_Domain:
        writer.writeByte(1);
        break;
      case SettingName.Electrum_Port:
        writer.writeByte(2);
        break;
      case SettingName.Electrum_DomainTest:
        writer.writeByte(3);
        break;
      case SettingName.Electrum_PortTest:
        writer.writeByte(4);
        break;
      case SettingName.Wallet_Current:
        writer.writeByte(5);
        break;
      case SettingName.Wallet_Preferred:
        writer.writeByte(6);
        break;
      case SettingName.Local_Path:
        writer.writeByte(7);
        break;
      case SettingName.User_Name:
        writer.writeByte(8);
        break;
      case SettingName.Send_Immediate:
        writer.writeByte(9);
        break;
      case SettingName.Lockout_Milliseconds:
        writer.writeByte(10);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingNameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
