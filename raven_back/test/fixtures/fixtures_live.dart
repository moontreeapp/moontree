import 'package:hive/hive.dart';
import 'package:raven/hive_initializer.dart';
import 'package:raven/raven.dart';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:raven/services/wallet/constants.dart';
import 'package:raven/utils/database.dart' as raven_database;

Future useLiveSources() async {
  dotenv.load();
  var mnemonic = dotenv.env['TEST_WALLET_01']!;
  var hiveInit = HiveInitializer(init: (dbDir) => Hive.init('database'));
  await hiveInit.setUp();
  await services.wallets.createSave(
      walletType: WalletType.leader,
      accountId: 'Primary',
      cipherUpdate: defaultCipherUpdate,
      secret: mnemonic);
  await services.accounts.createSave('Primary');
  await services.accounts.createSave('Savings');
  await initWaiters();
}

void deleteDatabase() => raven_database.deleteDatabase();
