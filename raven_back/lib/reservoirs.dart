import 'package:raven/reservoir/reservoir.dart';
import 'package:raven/models.dart' as models;
import 'package:raven/records.dart' as records;
//import 'package:raven/subjects/settings.dart';

//import 'listener.dart';

late Reservoir<records.Account, models.Account> accounts;
late Reservoir<records.Address, models.Address> addresses;
late Reservoir<records.History, models.History> histories;

void makeReservoirs() {
  //settings
  //    .map((s) => [s['electrum.url'], s['electrum.port']])
  //    .distinct()
  //    .listen((element) {
  //  print('port: ${element}');
  //});

  accounts =
      Reservoir(HiveBoxSource('accounts'), (account) => account.accountId);

  histories =
      Reservoir(HiveBoxSource('histories'), (histories) => histories.txHash)
        ..addIndex('account', (history) => history.accountId)
        ..addIndex('scripthash', (history) => history.scripthash);

  addresses =
      Reservoir(HiveBoxSource('addresses'), (address) => address.scripthash)
        ..addIndex('account', (address) => address.accountId)
        ..addIndex('account-exposure',
            (address) => '${address.accountId}:${address.exposure}');
}

//RavenElectrumClient generateClient() async {
//  return await RavenElectrumClient.connect('testnet.rvn.rocks');
//}
//
//String getConfig() {
//  return 'testnet.rvn.rocks';
//}
//