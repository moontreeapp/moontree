import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/wallet/constants.dart';
import 'package:ravencoin_back/streams/app.dart';
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
  streams.app.triggers.add(ThresholdTrigger.backup);
  final wallet = await services.wallet.createSave(
    walletType: walletType,
    mnemonic: mnemonic,
    getSecret: _getSecret,
    saveSecret: _saveSecret,
  );
  if (wallet is SingleWallet) {
    return await wallet.publicKey ?? '';
  }
  if (wallet is LeaderWallet) {
    return wallet.pubkey;
  }
  return wallet!.id;
}

Future setupRealWallet([String? id]) async {
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
    await setupRealWallet();
    await pros.settings.setCurrentWalletId(pros.wallets.first.id);
    await pros.settings.savePreferredWalletId(pros.wallets.first.id);
  }
}

Future<void> switchWallet(String walletId) async {
  /// CLAIM FEATURE -- actually don't clear it here, instead make it a map by walletId
  //streams.claim.unclaimed.add(<Vout>{});

  await pros.settings.setCurrentWalletId(walletId);
  streams.app.fling.add(false);
  streams.app.setting.add(null);
  final currentWallet = pros.wallets.primaryIndex.getOne(walletId);
  if (currentWallet is LeaderWallet && currentWallet.addresses.isEmpty) {
    await services.wallet.leader.handleDeriveAddress(leader: currentWallet);
  }
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
        records.add(LeaderWallet.from(
          wallet,
          name: wallet.name.isInt ? 'Wallet ${wallet.name}' : wallet.name,
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
      if (wallet.encryptedWIF != '') {
        records.add(SingleWallet.from(
          wallet,
          name: wallet.name.isInt ? 'Wallet ${wallet.name}' : wallet.name,
          encryptedWIF: '',
        ));
        await SecureStorage.writeSecret(Secret(
            secret: wallet.encryptedWIF,
            scripthash: wallet.id,
            secretType: SecretType.encryptedWif));
      }
    }
  }
  await pros.wallets.saveAll(records);
}

/// '1' -> 'Wallet 1'
Future<void> updateWalletNames() async {
  var records = <Wallet>[];
  for (var wallet in pros.wallets.records) {
    if (wallet is LeaderWallet) {
      if (wallet.name.isInt) {
        records.add(LeaderWallet.from(
          wallet,
          name: 'Wallet ${wallet.name}',
          seed: await wallet.seed,
          getEntropy: wallet.getEntropy,
        ));
      }
    } else if (wallet is SingleWallet) {
      if (wallet.name.isInt != '') {
        records.add(SingleWallet.from(
          wallet,
          name: 'Wallet ${wallet.name}',
        ));
      }
    }
  }
  await pros.wallets.saveAll(records);
}

/// we brought our enums into conformity by making the values lowercase, so we
/// should update the indexes of the boxes to reflect that.
Future<void> updateEnumLowerCase() async {
  var settings = pros.settings.records.toList();
  await pros.settings.delete();
  for (var setting in settings) {
    await pros.settings.save(Setting.from(setting), force: true);
  }
  if (pros.settings.chain == Chain.none) {
    await pros.settings.save(
        Setting(name: SettingName.blockchain, value: Chain.ravencoin),
        force: true);
    await pros.settings.save(
        Setting(name: SettingName.electrum_net, value: Net.main),
        force: true);
  }
  var rates = pros.rates.records.toList();
  var balances = pros.balances.records.toList();
  await pros.rates.delete();
  await pros.balances.delete();
  for (var rate in rates) {
    await pros.rates.save(Rate.from(rate), force: true);
  }
  for (var balance in balances) {
    await pros.balances.save(Balance.from(balance), force: true);
  }
}

Future<void> updateChain() async {
  var settings = pros.settings.records.toList();
  await pros.settings.delete();
  for (var setting in settings) {
    await pros.settings.save(Setting.from(setting), force: true);
  }
  if (pros.settings.chain == Chain.none) {
    await pros.settings.save(
        Setting(name: SettingName.blockchain, value: Chain.ravencoin),
        force: true);
    await pros.settings.save(
        Setting(name: SettingName.electrum_net, value: Net.main),
        force: true);
  }
  var assets = pros.assets.records.toList();
  var securities = pros.securities.records.toList();
  var metadatas = pros.metadatas.records.toList();
  var unspents = pros.unspents.records.toList();
  await pros.assets.delete();
  await pros.securities.delete();
  await pros.metadatas.delete();
  await pros.unspents.delete();
  for (var asset in assets) {
    await pros.assets.save(
        Asset.from(
          asset,
          chain: pros.settings.chain,
          net: pros.settings.net,
        ),
        force: true);
  }
  for (var security in securities) {
    await pros.securities.save(
        Security.from(
          security,
          chain: pros.settings.chain,
          net: pros.settings.net,
        ),
        force: true);
  }
  for (var metadata in metadatas) {
    await pros.metadatas.save(
        Metadata.from(
          metadata,
          chain: pros.settings.chain,
          net: pros.settings.net,
        ),
        force: true);
  }
  for (var unspent in unspents) {
    await pros.unspents.save(
        Unspent.from(
          unspent,
          chain: pros.settings.chain,
          net: pros.settings.net,
        ),
        force: true);
  }
}
