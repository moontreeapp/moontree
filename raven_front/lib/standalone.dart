import 'dart:io';
import 'package:flutter/material.dart';
//import 'package:bip39/bip39.dart' as bip39;
//import 'package:raven_electrum_client/raven_electrum_client.dart';
//import 'package:raven/boxes.dart';
//import 'package:raven/account.dart';
//import 'package:raven/accounts.dart';
//import 'package:raven/env.dart' as env;
//import 'package:raven/listen.dart' as listen;
//import 'pages/loading.dart';
//import 'pages/home.dart';
//import 'pages/choose_account.dart';

//Future setup() async {
//  await Directory('database').delete(recursive: true);
//  await Truth.instance.open();
//  await Accounts.instance.load();
//}
//
//void listenTo(RavenElectrumClient client) {
//  listen.toAccounts();
//  listen.toNodes(client);
//  listen.toUnspents();
//}

Future<void> main() async {
  // any setup stuff should happen on loading screen...
  //await setup();
  //var client = await RavenElectrumClient.connect('testnet.rvn.rocks');
  //listenTo(client);
  //var phrase = await env.getMnemonic();
  //var account = Account.bySeed(ravencoinTestnet, bip39.mnemonicToSeed(phrase));
  //await Truth.instance.saveAccount(account);
  //await Truth.instance.unspents
  //    .watch()
  //    .skipWhile((element) =>
  //        element.key !=
  //        '0d78acdf5fe186432cbc073921f83bb146d72c4a81c6bde21c3003f48c15eb38')
  //    .take(1)
  //    .toList();

  // should happen on home screen...
  runApp(MaterialApp(home: RavenApp()));
}

class RavenApp extends StatefulWidget {
  @override
  _RavenAppState createState() => _RavenAppState();
}

class _RavenAppState extends State<RavenApp> {
  //Accounts accounts = Accounts.instance;
  final List<String> accounts = [
    'a',
    'b',
    'c',
    'a',
    'b',
    'c',
    'a',
    'b',
    'c',
    'a',
    'b',
    'c',
    'a',
    'b',
    'c',
  ];
  late String chosen = 'a';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RavenApp'),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text('What is needed'),
            Divider(),
            Text(
              'Name:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(chosen),
            Text('edit button'),
            Text('delete button'),
            Text(''),
            Text(
              'Balance:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('balance'),
            Text(''),
            Text(
              'Sync:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('latest activity'),
            Text('refresh'),
            Text(''),
            Text(
              'Security:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('See account backup phrase'),
            Text(''),
            Text(
              'Transactions:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('List of Transactions'),
            Text('Send'),
            Text('Receive'),
            Text(''),
            Text(
              'Assets:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Create Asset'),
            Text('See list of assets'),
            Text('Trade Assets'),
            Text(''),
          ],
        ),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ...[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  children: <Widget>[Text('Accounts'), Text('overall Balance')],
                ),
              )
            ],
            ...accounts
                .map(
                  (e) => ListTile(
                    title: Text(e),
                    onTap: () {
                      setState(() {
                        chosen = e;
                      });
                    },
                  ),
                )
                .toList()
          ],
        ),
      ),
    );
  }
}
