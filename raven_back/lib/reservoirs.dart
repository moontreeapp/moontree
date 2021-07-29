import 'package:raven/services/reservoir_helper.dart';
import 'package:raven/reservoir/reservoir.dart';
//import 'package:raven/subjects/settings.dart';

//import 'listener.dart';
import 'models.dart';
import 'records/node_exposure.dart';

late Reservoir accounts;
late Reservoir addresses;
late Reservoir histories;
late Reservoir unspents;

void setup() {
  //settings
  //    .map((s) => [s['electrum.url'], s['electrum.port']])
  //    .distinct()
  //    .listen((element) {
  //  print('port: ${element}');
  //});

  accounts =
      Reservoir(HiveBoxSource('accounts'), (account) => account.accountId);

  histories = Reservoir(
      HiveBoxSource('histories'),
      (histories) =>
          '${histories.accountId}:${histories.scripthash}:${histories.txHash}');
  unspents = Reservoir(
      HiveBoxSource('unspents'),
      (unspents) =>
          '${unspents.accountId}:${unspents.scripthash}:${unspents.txHash}');

  addresses =
      Reservoir(HiveBoxSource('addresses'), (address) => address.scripthash)
        ..addIndex('account', (address) => address.accountId)
        ..addIndex('account-exposure',
            (address) => '${address.accountId}:${address.exposure}');

  var resHelper = ReservoirHelper(accounts, addresses);
}

//RavenElectrumClient generateClient() async {
//  return await RavenElectrumClient.connect('testnet.rvn.rocks');
//}
//
//String getConfig() {
//  return 'testnet.rvn.rocks';
//}
//