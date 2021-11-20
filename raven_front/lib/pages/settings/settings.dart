import 'package:flutter/material.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/components.dart';
import 'package:raven_mobile/services/ipfs.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:raven/utils/database.dart' as ravenDatabase;

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: components.headers.back(context, 'Settings'),
      body: SettingsList(
        contentPadding: EdgeInsets.only(top: 10),
        sections: [
          SettingsSection(title: 'Wallet', tiles: [
            SettingsTile(
                title: 'Import',
                leading: components.icons.import,
                onPressed: (BuildContext context) =>
                    Navigator.pushNamed(context, '/settings/import')),
            SettingsTile(
                title: 'Export / Backup',
                leading: components.icons.export,
                onPressed: (BuildContext context) => Navigator.pushNamed(
                    context, '/settings/export',
                    arguments: {'accountId': 'current'})),
            /*
            SettingsTile(
                title: 'Sign Message',
                enabled: false,
                leading: Icon(Icons.fact_check_sharp),
                onPressed: (BuildContext context) {
                  //Navigator.push(
                  //  context,
                  //  MaterialPageRoute(builder: (context) => ...()),
                  //);
                }),
            */
            SettingsTile(
                title: 'Accounts Overview',
                leading: Icon(Icons.lightbulb),
                onPressed: (BuildContext context) =>
                    Navigator.pushNamed(context, '/settings/technical')),
            /* Coming soon!
            SettingsTile(
                title: 'P2P Exchange',
                enabled: false,
                leading: Icon(Icons.swap_horiz),
                onPressed: (BuildContext context) {})
            */
          ]),
          SettingsSection(
            title: 'App',
            tiles: [
              SettingsTile(
                  title: 'Password',
                  leading: Icon(Icons.password),
                  onPressed: (BuildContext context) =>
                      Navigator.pushNamed(context, '/password/change')),
              SettingsTile(
                  title: 'Network',
                  leading: Icon(Icons.network_check),
                  onPressed: (BuildContext context) =>
                      Navigator.pushNamed(context, '/settings/network')),
              /*
              SettingsTile(
                  title: 'Currency',
                  leading: Icon(Icons.money),
                  onPressed: (BuildContext context) =>
                      Navigator.pushNamed(context, '/settings/currency')),
              SettingsTile(
                  title: 'Language',
                  subtitle: 'English',
                  leading: Icon(Icons.language),
                  onPressed: (BuildContext context) =>
                      Navigator.pushNamed(context, '/settings/language')),
              */
              SettingsTile(
                  title: 'About',
                  leading: Icon(Icons.info_outline_rounded),
                  onPressed: (BuildContext context) =>
                      Navigator.pushNamed(context, '/settings/about')),
              SettingsTile(
                  title: 'Clear Database',
                  leading: Icon(Icons.info_outline_rounded),
                  onPressed: (BuildContext context) {
                    ravenDatabase.deleteDatabase();
                  }),
              SettingsTile(
                  title: 'show data',
                  leading: Icon(Icons.info_outline_rounded),
                  onPressed: (BuildContext context) async {
                    //print(balances.data);
                    //print(transactions.primaryIndex.getOne(
                    //    '6984d492be101d0e76838369112f65e74472357cbd5d9820571e124032eeedf2'));
                    //var ipfsLogo =
                    //    'QmcVwukinT7BdC2u9PqyZRFG1dheebQGaBzgytJF6NZD9M';
                    ////var meta = MetadataGrabber(ipfsLogo);
                    ////print(await meta.get());
                    ////print(meta.logo);

                    print('---------------0');
                    var security = securities.bySymbolSecurityType
                        .getOne('MOONTREE0', SecurityType.RavenAsset)!;
                    print(security);

                    //print(sec.hasIpfs);
                    //print(Security.fromSecurity(sec, ipfsLogo: ipfsLogo));
                    //print(securities.data);
                    print('---------------1');
                    //var meta = MetadataGrabber(security.metadata);
                    //var ipfsLogo = '';
                    //if (await meta.get()) {
                    //  // if one is found... return true so we know you...
                    //  //   download the file and
                    //  //     save it to disk with the ipfsHash (for the logo)
                    //  //     as the name of the file
                    //  //   made the ipfsLogo hash available to us so we can
                    //  //     update the record.
                    //  ipfsLogo = meta.logo!;
                    //} // if one is not found... save the fact that we looked so we don't again.
                    //print(
                    //    'saving: ${Security.fromSecurity(security, ipfsLogo: ipfsLogo)}');
                    //await securities.remove(security); // must we remove first??
                    //await securities.save(
                    //    Security.fromSecurity(security, ipfsLogo: ipfsLogo));
                    //print('---------------2');
                    //security = securities.bySymbolSecurityType
                    //    .getOne('MOONTREE0', SecurityType.RavenAsset)!;
                    //print(security);
                  }),
/*                      
*/
              //SettingsTile.switchTile(
              //  title: 'Use fingerprint',
              //  leading: Icon(Icons.fingerprint),
              //  switchValue: true,
              //  onToggle: (bool value) {},
              //),
            ],
          ),
        ],
      ),
    );
  }
}
