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
        return SettingName.version_database;
      case 1:
        return SettingName.login_attempts;
      case 2:
        return SettingName.blockchain_net;
      case 3:
        return SettingName.electrum_domain;
      case 4:
        return SettingName.electrum_port;
      case 5:
        return SettingName.auth_method;
      case 6:
        return SettingName.blockchain;
      case 7:
        return SettingName.wallet_current;
      case 8:
        return SettingName.wallet_preferred;
      case 9:
        return SettingName.local_path;
      case 10:
        return SettingName.user_name;
      case 11:
        return SettingName.hide_fees;
      case 12:
        return SettingName.version_previous;
      case 13:
        return SettingName.version_current;
      case 14:
        return SettingName.mode_dev;
      case 15:
        return SettingName.tutorial_status;
      case 16:
        return SettingName.hidden_assets;
      default:
        return SettingName.version_database;
    }
  }

  @override
  void write(BinaryWriter writer, SettingName obj) {
    switch (obj) {
      case SettingName.version_database:
        writer.writeByte(0);
        break;
      case SettingName.login_attempts:
        writer.writeByte(1);
        break;
      case SettingName.blockchain_net:
        writer.writeByte(2);
        break;
      case SettingName.electrum_domain:
        writer.writeByte(3);
        break;
      case SettingName.electrum_port:
        writer.writeByte(4);
        break;
      case SettingName.auth_method:
        writer.writeByte(5);
        break;
      case SettingName.blockchain:
        writer.writeByte(6);
        break;
      case SettingName.wallet_current:
        writer.writeByte(7);
        break;
      case SettingName.wallet_preferred:
        writer.writeByte(8);
        break;
      case SettingName.local_path:
        writer.writeByte(9);
        break;
      case SettingName.user_name:
        writer.writeByte(10);
        break;
      case SettingName.hide_fees:
        writer.writeByte(11);
        break;
      case SettingName.version_previous:
        writer.writeByte(12);
        break;
      case SettingName.version_current:
        writer.writeByte(13);
        break;
      case SettingName.mode_dev:
        writer.writeByte(14);
        break;
      case SettingName.tutorial_status:
        writer.writeByte(15);
        break;
      case SettingName.hidden_assets:
        writer.writeByte(16);
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
