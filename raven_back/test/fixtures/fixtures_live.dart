import 'package:hive/hive.dart';
import 'package:raven_back/hive_initializer.dart';
import 'package:raven_back/raven_back.dart';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_back/utils/database.dart' as raven_database;

Future useLiveSources() async {
  dotenv.load();
  var mnemonic = dotenv.env['TEST_WALLET_01']!;
  var hiveInit = HiveInitializer(init: (dbDir) => Hive.init('database'));
  await hiveInit.setUp();
  await services.wallet.createSave(
      walletType: WalletType.leader,
      accountId: 'Primary',
      cipherUpdate: defaultCipherUpdate,
      secret: mnemonic);
  await services.account.createSave('Primary');
  await services.account.createSave('Savings');
  await initWaiters();
}

void deleteDatabase() => raven_database.deleteDatabase();
