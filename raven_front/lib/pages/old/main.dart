import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:raven/init/raven.dart' as raven;
import 'package:raven_mobile/services/account_mock.dart';

Future<void> main() async {
  await Hive.initFlutter();
  await dotenv.load(
    fileName: "assets/.env",
  );
  raven.init();
  //raven.addAccount... [dotenv.env['ACCOUNT0']!, dotenv.env['ACCOUNT1']!]

  // should happen on home screen...
  runApp(MaterialApp(home: RavenApp()));
}

class RavenApp extends StatefulWidget {
  @override
  _RavenAppState createState() => _RavenAppState();
}

class _RavenAppState extends State<RavenApp> {
  Map<String, String> accounts = Accounts.instance.accounts;
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
            Text('wallet type (HD vs single key)'),
            Text('edit (name) button'),
            Text('delete (wallet) button'),
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
            Text('See account backup phrase (export)'),
            Text(''),
            Text(
              'Transactions:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('List of Transactions'),
            Text('export Transactions'),
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
            ...accounts.keys
                .map(
                  (e) => ListTile(
                    title: Text(e),
                    onTap: () {
                      Navigator.pop(context);
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
