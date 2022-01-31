import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:raven_front/backdrop/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/streams.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/services/account.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:raven_back/extensions/list.dart';
import 'package:raven_back/utils/database.dart' as ravenDatabase;

//testing
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_electrum/methods/transaction/get.dart';

class NavDrawer extends StatefulWidget {
  NavDrawer({Key? key}) : super(key: key);

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  List listeners = [];

  @override
  void initState() {
    super.initState();
    //listeners.add(streams.app.page.stream.listen((value) {
    //  if (value != pageTitle) {
    //    setState(() {
    //      pageTitle = value;
    //    });
    //  }
    //}));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  Widget destination({
    required String name,
    required String link,
    IconData? icon,
    Image? image,
  }) =>
      TextButton.icon(
        onPressed: () {
          Backdrop.of(components.navigator.routeContext!).fling();
          Navigator.of(components.navigator.routeContext!).pushNamed(link);
        },
        icon: icon != null ? Icon(icon, color: Colors.white) : image!,
        label: Row(children: [
          SizedBox(width: 25),
          Text(name, style: Theme.of(context).drawerDestination)
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8),

      /// using a listview makes it variable so you don't have to define height
      //height: 300,
      //child: Column(
      //  crossAxisAlignment: CrossAxisAlignment.start,
      ///

      child: ListView(
        shrinkWrap: true,
        children: [
          destination(
            icon: MdiIcons.shieldKey,
            name: 'Import / Export',
            link: '/settings/import_export',
          ),
          destination(
            icon: Icons.settings,
            name: 'Settings',
            link: '/settings/settings',
          ),
          destination(
            icon: Icons.feedback,
            name: 'Feedback',
            link: '/settings/preferences',
          ),
          destination(
            icon: Icons.help,
            name: 'Support',
            link: '/settings/support',
          ),
          destination(
            icon: Icons.info_rounded,
            name: 'About',
            link: '/settings/about',
          ),

          ////SettingsTile(
          ////    title: 'Import/Export',
          ////    titleTextStyle: Theme.of(context).drawerDestination,
          ////    leading: Icon(Icons.account_balance_wallet,
          ////        color: Colors.white), // plus?
          ////    onPressed: (BuildContext context) =>
          ////        Navigator.pushNamed(context, '/settings/import')),
          ////SettingsTile(
          ////    title: 'Settings',
          ////    titleTextStyle: Theme.of(context).drawerDestination,
          ////    leading: Icon(Icons.settings, color: Colors.white),
          ////    onPressed: (BuildContext context) =>
          ////        Navigator.pushNamed(context, '/settings/preferences')),
          ////SettingsTile(
          ////    title: 'Feedback',
          ////    titleTextStyle: Theme.of(context).drawerDestination,
          ////    leading: Icon(Icons.feedback, color: Colors.white),
          ////    onPressed: (BuildContext context) =>
          ////        Navigator.pushNamed(context, '/settings/preferences')),
          ////SettingsTile(
          ////    title: 'Support',
          ////    titleTextStyle: Theme.of(context).drawerDestination,
          ////    leading: Icon(Icons.help, color: Colors.white),
          ////    onPressed: (BuildContext context) =>
          ////        Navigator.pushNamed(context, '/settings/preferences')),
          ////SettingsTile(
          ////    title: 'About',
          ////    titleTextStyle: Theme.of(context).drawerDestination,
          ////    leading: Icon(Icons.info_outline_rounded,
          ////        color: Colors.white),
          ////    onPressed: (BuildContext context) =>
          ////        Navigator.pushNamed(context, '/settings/about')),

          ////// These belong in Settings
          //accounts.length > 1 ?
          //SettingsTile(
          //    title: 'Accounts',
          //    subtitle: '(Detail)',
          //    titleTextStyle: Theme.of(context).drawerDestination,
          //    leading: Icon(Icons.lightbulb),
          //    onPressed: (BuildContext context) =>
          //        Navigator.pushNamed(context, '/settings/technical'))
          //: Text('');
          //
          //SettingsTile(
          //    title: 'Preferences',
          //    titleTextStyle: Theme.of(context).drawerDestination,
          //    leading: Icon(Icons.settings),
          //    onPressed: (BuildContext context) =>
          //        Navigator.pushNamed(context, '/settings/preferences')),
          //SettingsTile(
          //    title: 'Password',
          //    titleTextStyle: Theme.of(context).drawerDestination,
          //    leading: Icon(Icons.password),
          //    onPressed: (BuildContext context) =>
          //        Navigator.pushNamed(context, '/security/change')),
          //SettingsTile(
          //    title: 'Network',
          //    titleTextStyle: Theme.of(context).drawerDestination,
          //    leading: Icon(Icons.network_check),
          //    onPressed: (BuildContext context) =>
          //        Navigator.pushNamed(context, '/settings/network')),

          //SettingsTile(
          //    title: 'Export',
          //    subtitle: '(Backup)',
          //    titleTextStyle: Theme.of(context).drawerDestination,
          //    leading: components.icons.export,
          //    onPressed: (BuildContext context) => Navigator.pushNamed(
          //        context, '/settings/export',
          //        arguments: {'accountId': 'current'})),
          /*
            SettingsTile(
                title: 'Sign Message',
                titleTextStyle: Theme.of(context).drawerDestination,
                enabled: false,
                leading: Icon(Icons.fact_check_sharp),
                onPressed: (BuildContext context) {
                  //Navigator.push(
                  //  context,
                  //  MaterialPageRoute(builder: (context) => ...()),
                  //);
                }),
            */

          /* Coming soon!
            SettingsTile(
                title: 'P2P Exchange',
                titleTextStyle: Theme.of(context).drawerDestination,
                enabled: false,
                leading: Icon(Icons.swap_horiz),
                onPressed: (BuildContext context) {})
            */

          /*
              SettingsTile(
                  title: 'Currency',
                  titleTextStyle: Theme.of(context).drawerDestination,
                  leading: Icon(Icons.money),
                  onPressed: (BuildContext context) =>
                      Navigator.pushNamed(context, '/settings/currency')),
              SettingsTile(
                  title: 'Language',
                  titleTextStyle: Theme.of(context).drawerDestination,
                  subtitle: 'English',
                  leading: Icon(Icons.language),
                  onPressed: (BuildContext context) =>
                      Navigator.pushNamed(context, '/settings/language')),
              */

/*
*/
          SettingsTile(
              title: 'Clear Database',
              titleTextStyle: Theme.of(context).drawerDestination,
              leading: Icon(Icons.info_outline_rounded),
              onPressed: (BuildContext context) {
                ravenDatabase.deleteDatabase();
              }),
          destination(
            icon: MdiIcons.shieldKey,
            name: 'Accounts',
            link: '/settings/technical',
          ),
          SettingsTile(
              title: 'show data',
              titleTextStyle: Theme.of(context).drawerDestination,
              leading: Icon(Icons.info_outline_rounded),
              onPressed: (BuildContext context) async {
                var allTx = [
                  '8cc0b9a82f5f5a54d6539b92ee1ea5895eaada63234c721102a1e49a2c0f2627',
                  '86f9493e07cb039a3735ca7ac074a869464488d961ad60844134820fa67d6a56',
                  '9b64eb258a4352a68c4ce98cbbadddcbbcb285c422f7f9f97ed4b826d0a387d7',
                  'c88fe87a5df1f8fac0ba929a7021038d66947fd4aabef2368eb7aa21aea2c3c5',
                  '7217229e9fa0e668aebc4d1478ab69320ee7d9b6ca6357c30a38b4b4a89a0c0d',
                  '5cdde1dc17f820320011ec648272237322e1cde48e62158b3cb56999c5aba0e8',
                  '53572c6054e8c00b847ed19682e487b1a44b4a28c3a6001bd84473db1c671044',
                  '6ef14bbacb9dc343eb9cde1f2a311ae787231613fc6ae863cec11752a56c3308',
                  '17b798480e340ae639c23a036ee39d61784b4418ca3d40c43ae2e7c9728e76e2',
                  '6b5d00227fc75b590d693877a32ecce55664fd851238de1cfa3fae5ce1362862',
                  '24031e0a46ae015cdb58d53dfb8910207d53b6a061387ffd2368730533043f3e',
                  '14de222d2825ec8e187e4d8c2785bdf26663d6d8e9f5475cb97a5e6376a64d56',
                  'ef1be6f06025e6bd8d7e8319003296e168068ce9d08e6efc1612c06fcb13c330',
                  '5fd5dc8fbb486404feb24762a838c09131d225b3547b9fa318920d1593591139',
                  '00111be079656f15bc63afa843860f37e0ecbc6e374c2e35c11fac6eff9cb810',
                  'fe08c278ad54f3fdcc35aa6d05de7b955f22d842d9ef75a501fa82aa68dbc178',
                  '47f0fc510a930c56797d5bf2ed574e9a7d67153d8e34e6b342af6947d0efdddf',
                  'e80568e961b4a978dcf5ab533638505823bbb83bbea2c742afb35f6b22ff96b6',
                  'c512010a793a7a4296e1a34e1c11b94441226f602cf57c9b56d3a20307f02b41',
                  'f585233ccb19f93912c094e66d5681b73a4adcf3db50c7455e5d9b2a724b2345',
                  '681c62266f6dc3c1c16ba5024c5bb875c627ab89815fd61f689519e06036832b',
                  'c4824d89f01fff6af19387d8aa51adaaf49e509d17f766740e5524a89e557baf',
                  '31a331097670a2b76caafefcf74ccb26e38ac3949e05e44c08a84f30c1ee998b',
                  '9bc5463610b074a5aa4ea6045c983fbdd787548edccae732e000524b96833713',
                  '86f9493e07cb039a3735ca7ac074a869464488d961ad60844134820fa67d6a56',
                  '90bf9bb181cb83dd9804a0a03186e6ae81a66ea738f3afd6b472387feb16d155',
                  'd5df08a40715ce1669cb51792a3a66651d4803f3a26ea9f4603d135b00f5ae37',
                  'd1ce79279cf472930b59992a91b1bf1f97f1fa20e5853b4167020097c5eb3de7',
                  '6157c77511af147fad4f90c304bf08cb996b701fa4449176dfa571cfbb96c538',
                  'd5df08a40715ce1669cb51792a3a66651d4803f3a26ea9f4603d135b00f5ae37',
                  'b88b0dcf16a15f5f94d43c24787a05df0bbfeeb31e9851d5dd4a163272fa6246',
                  '8f47fd4460bb509717abd5629592c68b34befbe16ad1fcec0f4ccf02801d8972',
                  '81c5368a096785577e6d7e7b3cd8003e726c0b4b54d466de60e17c912a68fbf9',
                  'a4c98b02009d93720ecd75f25c7140d90142fbd2899178482227a5a064afb144',
                  '661a2db68b3e8dbf5415ea89dd58a233c2c4a41a8daf025802f1abcc2c99905d',
                  'ef1c38030c19f65da67ab32bf57276e5c729948b509a6051c6707de8a65a163e',
                  '056f967339e578eee83f18f53c5d0d5212f05f2a7bd09daace7cf445ba593738',
                  'b13feb18ae0b66f47e1606230b0a70de7d40ab52fbfc5626488136fbaa668b34',
                  'b13feb18ae0b66f47e1606230b0a70de7d40ab52fbfc5626488136fbaa668b34',
                  '941958f0a867da5f1f377a195789c65f7ed4a5cfebf5d67a2984265a485d8997',
                  '17ffe035975ff89ca6674d94a2f0bfab965cf4b1127ccbd0a2cc659deefe3f31',
                  'b88b0dcf16a15f5f94d43c24787a05df0bbfeeb31e9851d5dd4a163272fa6246',
                  'a4c98b02009d93720ecd75f25c7140d90142fbd2899178482227a5a064afb144',
                  '661a2db68b3e8dbf5415ea89dd58a233c2c4a41a8daf025802f1abcc2c99905d',
                  '592ef253d19fbea6ed5944d52b962672818446afda21acc90ba5a2765dcedfcd',
                  'e21908318dbfc960a55d2b6bb5445c32037e8a87be2985c500ef9057cafa4e58',
                  '480885f8f02af18bea569879d206214c21ac049c38edc7e1d637fa3b71096f1e',
                  'd7fbd716a31d435873ecce6c3d28755b7a87c2d4e77ce019912320b510cbf994',
                  '9c0175c81d47fb3e8d99ec5a7b7f901769185682ebad31a8fcec9f77c656a97f',
                  '6157c77511af147fad4f90c304bf08cb996b701fa4449176dfa571cfbb96c538',
                  '90bf9bb181cb83dd9804a0a03186e6ae81a66ea738f3afd6b472387feb16d155',
                  'a6a58a43cc0a28041a5a6de36caedc318a4c666ef137e4d60a3038d90fe6f554',
                  '237e0d6d8797327765d42bed9fa4f6debef59f8d720ed4c85d7ebd704831c781',
                  '4fec4a48431bb4787e4953555444bfa644bb25e3a731b677255ca954967a856d',
                  '8ac0511768f9610e88631dd8ed9c3be4e695429eca09259182487ebacbce114b',
                  'f5aef6a132178870185991f0bc5a71a26d8b4a91168df15f99536a0c977d3525',
                  '1f317dd90d95c785cc9ed631cef06cc33b064b3bd30e784f6b02146ebde581ec',
                  'f3452cbba6d533b6e20e574e4bfdb6dc81aaf8d3e6d56fdbbcbb158ef16d2500',
                  '30b820ae12936fbce6e702c7e9398edb6c7372f9c3af5b780d75af6f2e38ecb1',
                  'f482eed82afd29aba49a07b3384f613962d7ac1d3e5da00365010b1d6945536a',
                  'b83f7088ce3c1498dbb425b6e1eb1be6a0f4eaada62de615add50d2fe4acd8ee',
                  '16b56147209e283fd53961ffd89ae44b96b071827664f8e160be9d5f49ae61e2',
                  '78bcf1b919e6e720c6d01d20a25cf50011bf8a9489514fec16b133a4274a43e8',
                  'fb25abf83f4777a5d13206d5bf92ef9f51ecd8f1d0bdbfff97549e15c96b2d9a',
                  '82f879eed5857757ba9342451d24ae9253822877ad82957bec372d0986e4ca23',
                  '9fe4e97a716808e40991cbb9a31c4bd789a008fdcc92beada4a34538ee333397',
                  '65e6bd3b0290983df6b96ad0c66c5ddfe3a34d19e7467a40e05a3d7a8f76d1a6',
                  'bb772cad2f0942e0bc30ad85f4a42985fe977ea52759538983f6d3b38636d3dd',
                  'a6a58a43cc0a28041a5a6de36caedc318a4c666ef137e4d60a3038d90fe6f554',
                  '31a331097670a2b76caafefcf74ccb26e38ac3949e05e44c08a84f30c1ee998b',
                  '9bc5463610b074a5aa4ea6045c983fbdd787548edccae732e000524b96833713',
                  '65e6bd3b0290983df6b96ad0c66c5ddfe3a34d19e7467a40e05a3d7a8f76d1a6',
                  'e60b13e882f89cd2cdc1d57d74479b317954512b426dccce7e7ded5ea1f181dc',
                  '73829f290348b43f8898a1da9a3545ecfe8224d7f66d6f112693720f11801274',
                  '02a913fd26e02edd17e3aabcb9245acb02223a9ff3262f9da294b8aecda6872a',
                  '81c5368a096785577e6d7e7b3cd8003e726c0b4b54d466de60e17c912a68fbf9',
                  'ef1c38030c19f65da67ab32bf57276e5c729948b509a6051c6707de8a65a163e',
                  '17ffe035975ff89ca6674d94a2f0bfab965cf4b1127ccbd0a2cc659deefe3f31',
                  '8f47fd4460bb509717abd5629592c68b34befbe16ad1fcec0f4ccf02801d8972',
                  '8cc0b9a82f5f5a54d6539b92ee1ea5895eaada63234c721102a1e49a2c0f2627',
                  '73829f290348b43f8898a1da9a3545ecfe8224d7f66d6f112693720f11801274',
                  'af288ad6f644f3123c5828f6cccc42e2e38c1acf88e3eb2f1e13732fea2f93ae',
                  'bae05a0081d4d6820ee87d9b84261028d0d23a0923becfda00dc352c6d3583c5',
                  'e9ec208d98a621758af246f5c9253843cdbb744365eb234cc8eb201f002ca280',
                  'a198fa666aaee3fed3d9ad18c6a8fd3443918be854e59221d0c9edd76da9d3bf',
                  '5e92d7072ec001bec67be4c97363b6b92c6677ddc49f4dd017645049ec2407bb',
                  '6ce9151422d28f9434edad6f8e25abe251a382b26096f05a0eba8465403c572e',
                  '4a74bcb3a4079554f47c1fe42604355eb5796b83344f7f0e87ec6473408e6ea3',
                  '2c0326ebe52bc3cab2586cdca09da44e692aa82d523661adda5174d2fbc17d1e',
                  'f313cdc0b929f33259ab47fad7aab5e6d1d21b4df2f60f2e224c81b3b0b65f24',
                  'f40744571d77ec1d6447feae81d2febe9959dd9074613425d2ab5c5d8a9fb90a',
                  'b7a412f090a621d5719a55f20a3718df0980520835f09142b1167785e8eae16d',
                  '0d9da5fbd3a4401b21157d66bfad4988a5e5287feb7da0a683fa8cd006c9e994',
                  '0ef1ada073022616411fb1b654ad7fbeb7eef7d57b2fe8bdfa324e15e838f853',
                  '743b991dedaef70aae545219f1fd7cc14ccdaefc34c20f679e46664d0f78bfc1',
                  'f12731e5eb08942f1167a24a615fc11b6ee0cbb0827723d320da1820020a05dc',
                  'a2f9125194906f3f8f0081f6352fb26aff51c1ab629eaaa05ad4a9c9f79983ab',
                  '9fe2a5d640f4c2bc9b2445d0cd8d3fe158983277c5e237866c4d5302015ebc72',
                  '9bc5463610b074a5aa4ea6045c983fbdd787548edccae732e000524b96833713',
                  '4e769a6d770b4e441ade1d5600926ad14f58fdb6ae4128ed03c811241ec72240',
                  'bb772cad2f0942e0bc30ad85f4a42985fe977ea52759538983f6d3b38636d3dd',
                  '237e0d6d8797327765d42bed9fa4f6debef59f8d720ed4c85d7ebd704831c781',
                  'd1ce79279cf472930b59992a91b1bf1f97f1fa20e5853b4167020097c5eb3de7',
                  '02a913fd26e02edd17e3aabcb9245acb02223a9ff3262f9da294b8aecda6872a',
                ];
                var txs = res.transactions.data.map((e) => e.transactionId);
                for (var tx in txs) {
                  if (allTx.contains(tx)) {
                    print('$tx found');
                  } else {
                    print('$tx ?');
                  }
                }
                //var txHash =
                //    //'9b64eb258a4352a68c4ce98cbbadddcbbcb285c422f7f9f97ed4b826d0a387d7';
                //    '5cdde1dc17f820320011ec648272237322e1cde48e62158b3cb56999c5aba0e8';
                //var client = streams.client.client.value!;
                //var tx = await client.getTransaction(txHash);
                //print('---tx');
                //print(tx.txid);
                //print(tx);
                //print('---vin len');
                //print(tx.vin.length);
                //print('---vin 0');
                //print(tx.vin[0].txid);
                //print(tx.vin[0].vout);
                //print('---vin 1');
                //print(tx.vin[1].txid);
                //print(tx.vin[1].vout);
                //services.history.saveTransactions([tx], client);
                //for (var item in [
                //  '681c62266f6dc3c1c16ba5024c5bb875c627ab89815fd61f689519e06036832b',
                //  'f585233ccb19f93912c094e66d5681b73a4adcf3db50c7455e5d9b2a724b2345',
                //  '47f0fc510a930c56797d5bf2ed574e9a7d67153d8e34e6b342af6947d0efdddf',
                //  'e80568e961b4a978dcf5ab533638505823bbb83bbea2c742afb35f6b22ff96b6',
                //  'c512010a793a7a4296e1a34e1c11b94441226f602cf57c9b56d3a20307f02b41',
                //  'fe08c278ad54f3fdcc35aa6d05de7b955f22d842d9ef75a501fa82aa68dbc178',
                //  '00111be079656f15bc63afa843860f37e0ecbc6e374c2e35c11fac6eff9cb810',
                //  '5fd5dc8fbb486404feb24762a838c09131d225b3547b9fa318920d1593591139',
                //  'ef1be6f06025e6bd8d7e8319003296e168068ce9d08e6efc1612c06fcb13c330',
                //  '14de222d2825ec8e187e4d8c2785bdf26663d6d8e9f5475cb97a5e6376a64d56',
                //  '24031e0a46ae015cdb58d53dfb8910207d53b6a061387ffd2368730533043f3e',
                //  '6b5d00227fc75b590d693877a32ecce55664fd851238de1cfa3fae5ce1362862',
                //  '17b798480e340ae639c23a036ee39d61784b4418ca3d40c43ae2e7c9728e76e2',
                //  '6ef14bbacb9dc343eb9cde1f2a311ae787231613fc6ae863cec11752a56c3308',
                //  '53572c6054e8c00b847ed19682e487b1a44b4a28c3a6001bd84473db1c671044',
                //  '5cdde1dc17f820320011ec648272237322e1cde48e62158b3cb56999c5aba0e8',
                //  '7217229e9fa0e668aebc4d1478ab69320ee7d9b6ca6357c30a38b4b4a89a0c0d',
                //  'c88fe87a5df1f8fac0ba929a7021038d66947fd4aabef2368eb7aa21aea2c3c5',
                //  '9b64eb258a4352a68c4ce98cbbadddcbbcb285c422f7f9f97ed4b826d0a387d7',
                //]) {
                //  var tx = res.transactions.primaryIndex.getOne(item);
                //  print(tx);
                //}

                //var add = res.addresses.byAddress
                //    .getOne('ms9vMzmK3KB9j6gsLSXaLKKzfF17umue3D')!;
                //print(add);
                //print(add.address);
                //print(add.walletId);
                //print(add.hdIndex);
                //print(add.exposure);
                //print(add.vouts);

                //print(res.vouts.byAddress
                //    .getAll('ms9vMzmK3KB9j6gsLSXaLKKzfF17umue3D'));
                //print(res.vins.byVoutId.getOne(
                //    '86f9493e07cb039a3735ca7ac074a869464488d961ad60844134820fa67d6a56:0'));
                //print(res.vouts.primaryIndex
                //    .getOne(
                //        '90bf9bb181cb83dd9804a0a03186e6ae81a66ea738f3afd6b472387feb16d155:0')!
                //    .vin);
                //var tx = res.vouts.data
                //    //VoutReservoir.whereUnspent(includeMempool: false)
                //    .where((Vout vout) =>
                //        vout.account?.net ==
                //            res.settings.primaryIndex
                //                .getOne(SettingName.Electrum_Net)!
                //                .value &&
                //        (vout.transaction?.confirmed ?? false))
                //    .map((e) => e.assetSecurityId)
                //    .toList();
                //for (var id in tx) {
                //  print(id);
                //}
                //var tx = res.transactions.data;
              }),
/*
*/

          //SettingsTile.switchTile(
          //  title: 'Use fingerprint',
          //  titleTextStyle: Theme.of(context).drawerDestination,
          //  leading: Icon(Icons.fingerprint),
          //  switchValue: true,
          //  onToggle: (bool value) {},
          //),
        ],
      ),
    );
  }
}
