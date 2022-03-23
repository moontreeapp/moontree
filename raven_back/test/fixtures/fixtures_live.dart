import 'package:hive/hive.dart';
import 'package:raven_back/hive_initializer.dart';
import 'package:raven_back/raven_back.dart';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_back/utilities/database.dart' as raven_database;

Future useLiveSources() async {
  dotenv.load();
  var mnemonic = dotenv.env['TEST_WALLET_01']!;
  var hiveInit = HiveInitializer(init: (dbDir) => Hive.init('database'));
  await hiveInit.setUp();
  await services.wallet.createSave(
      walletType: WalletType.leader,
      cipherUpdate: defaultCipherUpdate,
      secret: mnemonic);
  await initWaiters();
}

void deleteDatabase() => raven_database.deleteDatabase();
