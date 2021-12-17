import 'package:raven_back/records/records.dart';

Map<String, Setting> get settings => {
      'Send_Immediate': Setting(name: SettingName.Send_Immediate, value: true),
      'User_Name':
          Setting(name: SettingName.User_Name, value: 'Satoshi Nakamoto'),
    };
