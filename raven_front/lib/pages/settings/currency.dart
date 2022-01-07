import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class Currency extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsList(sections: [
      SettingsSection(tiles: [
        CurrencyTile('USD', enabled: true),
        CurrencyTile('EUR', icon: Icons.euro),
        CurrencyTile('CAD'),
        CurrencyTile('GBP'),
        CurrencyTile('JPY'),
        CurrencyTile('NZD'),
        CurrencyTile('RUB'),
      ])
    ]);
  }
}

class CurrencyTile extends SettingsTile {
  CurrencyTile(
    currency, {
    icon = Icons.money,
    enabled = false,
  }) : super(
            title: currency,
            enabled: enabled,
            leading: Icon(icon),
            onPressed: (BuildContext context) {});
}
