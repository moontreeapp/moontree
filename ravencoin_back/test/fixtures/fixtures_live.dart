import 'package:hive/hive.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:ravencoin_back/services/wallet/constants.dart';
import 'package:ravencoin_back/utilities/database.dart' as raven_database;

Future useLiveSources() async {
  dotenv.load();
  var mnemonic = dotenv.env['TEST_WALLET_01']!;
  var hiveInit = HiveInitializer(init: (dbDir) => Hive.init('database'));
  await hiveInit.setUp(HiveLoadingStep.All);
  initWaiters(HiveLoadingStep.All);
  await services.wallet.createSave(
      walletType: WalletType.leader,
      cipherUpdate: defaultCipherUpdate,
      secret: mnemonic);
  await pros.settings.setCurrentWalletId(pros.wallets.first.id);
  await pros.settings.savePreferredWalletId(pros.wallets.first.id);
}

void deleteDatabase() => raven_database.deleteDatabase();
