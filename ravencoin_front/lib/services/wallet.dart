import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/wallet/constants.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;

Future<String> Function(String id) get getEntropy => _getSecret;
Future<void> Function(Secret secret) get saveSecret => _saveSecret;

Future<String> _getSecret(String id) async =>
    await SecureStorage.read(id) ?? '';

Future<void> _saveSecret(Secret secret) async =>
    await SecureStorage.writeSecret(secret);

Future<String> generateWallet({
  WalletType? walletType,
  String? mnemonic,
}) async {
  final wallet = await services.wallet.createSave(
    walletType: walletType,
    mnemonic: mnemonic,
    getSecret: _getSecret,
    saveSecret: _saveSecret,
  );
  if (wallet is SingleWallet) {
    return wallet.publicKey ?? '';
  }
  if (wallet is LeaderWallet) {
    return wallet.pubkey;
  }
  return wallet!.id;
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
      wallet.setSecret(_getSecret);
    } else if (wallet is SingleWallet) {
      wallet.setSecret(_getSecret);
    }
  }
}

/// moves entropy to secure storage
Future<void> updateWalletsToSecureStorage() async {
  var records = <Wallet>[];
  for (var wallet in pros.wallets.records) {
    if (wallet is LeaderWallet) {
      if (wallet.encryptedEntropy != '') {
        wallet.encryptedEntropy;
        records.add(LeaderWallet.from(
          wallet,
          encryptedEntropy: '',
          seed: await wallet.seed,
          getEntropy: wallet.getEntropy,
        ));
        await SecureStorage.writeSecret(Secret(
            secret: wallet.encryptedEntropy,
            pubkey: wallet.pubkey,
            secretType: SecretType.encryptedEntropy));
      }
    } else if (wallet is SingleWallet) {
      records.add(SingleWallet.from(wallet, encryptedWIF: ''));
      await SecureStorage.writeSecret(Secret(
          secret: wallet.encryptedWIF,
          scripthash: wallet.id,
          secretType: SecretType.encryptedWif));
    }
  }
  await pros.wallets.saveAll(records);
}
