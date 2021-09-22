// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_name.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingNameAdapter extends TypeAdapter<SettingName> {
  @override
  final int typeId = 103;

  @override
  SettingName read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SettingName.Electrum_Url;
      case 1:
        return SettingName.Electrum_Port;
      case 2:
        return SettingName.Account_Current;
      case 3:
        return SettingName.Account_Preferred;
      default:
        return SettingName.Electrum_Url;
    }
  }

  @override
  void write(BinaryWriter writer, SettingName obj) {
    switch (obj) {
      case SettingName.Electrum_Url:
        writer.writeByte(0);
        break;
      case SettingName.Electrum_Port:
        writer.writeByte(1);
        break;
      case SettingName.Account_Current:
        writer.writeByte(2);
        break;
      case SettingName.Account_Preferred:
        writer.writeByte(3);
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
