import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/wallet/constants.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;

Future<Future<String> Function(String id)> get getEntropy async => _getEntropy;
Future<Future<void> Function(Secret secret)> get saveSecret async =>
    _saveSecret;

Future<String> _getEntropy(String id) async =>
    await SecureStorage.read(id) ?? '';

Future<void> _saveSecret(Secret secret) async =>
    await SecureStorage.writeSecret(secret);

Future<String> generateWallet({
  WalletType? walletType,
  String? mnemonic,
}) async {
  final secret = await services.wallet.createSave(
    walletType: walletType,
    mnemonic: mnemonic,
    getEntropy: _getEntropy,
    saveSecret: _saveSecret,
  );
  return secret!.pubkey!;
}

Future setupRealWallet(String? id) async {
  final mnemonic;
  if (id != null) {
    await dotenv.load(fileName: '.env');
    mnemonic = dotenv.env['TEST_WALLET_0$id']!;
  } else {
    mnemonic = null;
  }
  await generateWallet(walletType: WalletType.leader, mnemonic: mnemonic);
}

Future setupWallets() async {
  if (pros.wallets.records.isEmpty) {
    await setupRealWallet('1');
    await pros.settings.setCurrentWalletId(pros.wallets.first.id);
    await pros.settings.savePreferredWalletId(pros.wallets.first.id);
  }
}

Future<void> switchWallet(String walletId) async {
  await pros.settings.setCurrentWalletId(walletId);
  streams.app.fling.add(false);
  streams.app.setting.add(null);
}

Future<void> populateWalletsWithSensitives() async {
  for (var wallet in pros.wallets.records) {
    if (wallet is LeaderWallet) {
      //await pros.wallets
      //    .save(LeaderWallet.from(wallet, getEntropy: _getEntropy));
      wallet.setEntropy(_getEntropy);
    } else if (wallet is SingleWallet) {
      //await pros.wallets
      //    .save(SingleWallet.from(wallet, getEntropy: _getEntropy));
    }
  }
}
