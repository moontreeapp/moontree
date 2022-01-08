import 'package:flutter/material.dart';
import 'package:raven_front/theme/extensions.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(left: 0, right: 0, top: 2),
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.lock_rounded, color: Color(0x99000000)),
          title: Text('Security', style: Theme.of(context).settingDestination),
          trailing: Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).pushNamed('/settings/security'),
        ),
        Divider(height: 1),
        ListTile(
          leading: Image.asset('assets/icons/user_level/user_level.png'),
          title:
              Text('User Level', style: Theme.of(context).settingDestination),
          trailing: Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).pushNamed('/settings/level'),
        ),
        Divider(height: 1),
        ListTile(
          leading: Image.asset('assets/icons/network/network.png'),
          title: Text('Network', style: Theme.of(context).settingDestination),
          trailing: Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).pushNamed('/settings/network'),
        ),
        Divider(height: 1),
      ],
    );
  }
}
