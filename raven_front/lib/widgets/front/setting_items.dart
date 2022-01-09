import 'package:flutter/material.dart';
import 'package:raven_back/extensions/object.dart';
import 'package:raven_back/extensions/string.dart';
import 'package:raven_front/theme/extensions.dart';

enum UISettingName { Security, User_Level, Network, Import, Export }

class SettingItems extends StatefulWidget {
  final List<UISettingName> names;

  const SettingItems({Key? key, required this.names}) : super();

  @override
  State createState() => new _SettingItemsState();
}

class _SettingItemsState extends State<SettingItems> {
  String asString(UISettingName name) =>
      name.enumString.toTitleCase(underscoreAsSpace: true);

  Widget leads(UISettingName name) =>
      {
        UISettingName.Security:
            Icon(Icons.lock_rounded, color: Color(0x99000000)),
        UISettingName.User_Level:
            Image.asset('assets/icons/user_level/user_level.png'),
        UISettingName.Network: Image.asset('assets/icons/network/network.png'),
        UISettingName.Import:
            Image.asset('assets/icons/import_export/import_file.png'),
        UISettingName.Export:
            Image.asset('assets/icons/import_export/export_file.png'),
      }[name] ??
      Icon(Icons.home_rounded, color: Color(0x99000000));

  String links(UISettingName name) =>
      {
        UISettingName.Security: '/settings/security',
        UISettingName.User_Level: '/settings/level',
        UISettingName.Network: '/settings/network',
        UISettingName.Import: '/settings/import',
        UISettingName.Export: '/settings/export',
      }[name] ??
      '/home';

  Widget item(UISettingName name) => ListTile(
        leading: leads(name),
        title:
            Text(asString(name), style: Theme.of(context).settingDestination),
        trailing: Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.of(context).pushNamed(links(name)),
      );

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(left: 0, right: 0, top: 2),
      children: <Widget>[
        for (var name in widget.names) ...[
          item(name),
          Divider(height: 1),
        ]
      ],
    );
  }
}
