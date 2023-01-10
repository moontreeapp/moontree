import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wallet_utils/src/utilities/validation_ext.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/services/wallet/constants.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/services/dev.dart';
import 'package:client_front/services/lookup.dart';
import 'package:client_front/services/storage.dart' show SecureStorage;
import 'package:bip32/bip32.dart';

Future<String> Function(String id) get getEntropy => _getSecret;
Future<void> Function(Secret secret) get saveSecret => _saveSecret;

Future<String> _getSecret(String id) async =>
    await SecureStorage.read(id) ?? '';

Future<void> _saveSecret(Secret secret) async =>
    SecureStorage.writeSecret(secret);

Future<String> generateWallet({
  WalletType? walletType,
  String? mnemonic,
}) async {
  streams.app.triggers.add(ThresholdTrigger.backup);
  final Wallet? wallet = await services.wallet.createSave(
    walletType: walletType,
    mnemonic: mnemonic,
    backedUp: devFlags.contains(DevFlag.skipBackup),
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

Future<void> setupRealWallet([String? id]) async {
  final String? mnemonic;
  if (id != null) {
    await dotenv.load();
    mnemonic = dotenv.env['TEST_WALLET_0$id'];
  } else {
    mnemonic = null;
  }
  await generateWallet(walletType: WalletType.leader, mnemonic: mnemonic);
}

Future<void> setupWallets() async {
  if (pros.wallets.records.isEmpty) {
    await setupRealWallet();
    await pros.settings.setCurrentWalletId(pros.wallets.first.id);
    await pros.settings.savePreferredWalletId(pros.wallets.first.id);
  }
}

Future<void> switchWallet(String walletId) async {
  if (streams.client.busy.value) {
    await services.client.disconnect();
    await services.client.createClient();
  }

  await pros.settings.setCurrentWalletId(walletId);
  streams.app.fling.add(false);
  streams.app.setting.add(null);
  final Wallet? currentWallet = pros.wallets.primaryIndex.getOne(walletId);
  if (currentWallet is LeaderWallet && currentWallet.addressesFor().isEmpty) {
    await services.wallet.leader.handleDeriveAddress(leader: currentWallet);
  }
}

Future<void> populateWalletsWithSensitives() async {
  for (final Wallet wallet in pros.wallets.records) {
    if (wallet is LeaderWallet) {
      wallet.setSecret(_getSecret);
    } else if (wallet is SingleWallet) {
      wallet.setSecret(_getSecret);
    }
  }
}

/// moves entropy to secure storage
Future<void> updateWalletsToSecureStorage() async {
  final List<Wallet> records = <Wallet>[];
  for (final Wallet wallet in pros.wallets.records) {
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
  final List<Wallet> records = <Wallet>[];
  for (final Wallet wallet in pros.wallets.records) {
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
      if (wallet.name.isInt) {
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
  final List<Setting> settings = pros.settings.records.toList();
  await pros.settings.delete();
  for (final Setting setting in settings) {
    await pros.settings.save(Setting.from(setting), force: true);
  }
  if (pros.settings.chain == Chain.none) {
    await pros.settings.save(
        const Setting(name: SettingName.blockchain, value: Chain.ravencoin),
        force: true);
    await pros.settings.save(
        const Setting(name: SettingName.blockchain_net, value: Net.main),
        force: true);
  }
  final List<Rate> rates = pros.rates.records.toList();
  final List<Balance> balances = pros.balances.records.toList();
  await pros.rates.delete();
  await pros.balances.delete();
  for (final Rate rate in rates) {
    await pros.rates.save(Rate.from(rate), force: true);
  }
  for (final Balance balance in balances) {
    await pros.balances.save(Balance.from(balance), force: true);
  }
}

Future<void> updateChain() async {
  final List<Setting> settings = pros.settings.records.toList();
  await pros.settings.delete();
  for (final Setting setting in settings) {
    await pros.settings.save(Setting.from(setting), force: true);
  }
  if (pros.settings.chain == Chain.none) {
    await pros.settings.save(
        const Setting(name: SettingName.blockchain, value: Chain.ravencoin),
        force: true);
    await pros.settings.save(
        const Setting(name: SettingName.blockchain_net, value: Net.main),
        force: true);
  }
  final List<Asset> assets = pros.assets.records.toList();
  final List<Security> securities = pros.securities.records.toList();
  final List<Metadata> metadatas = pros.metadatas.records.toList();
  final List<Unspent> unspents = pros.unspents.records.toList();
  await pros.assets.delete();
  await pros.securities.delete();
  await pros.metadatas.delete();
  await pros.unspents.delete();
  for (final Asset asset in assets) {
    await pros.assets.save(
        Asset.from(
          asset,
          chain: pros.settings.chain,
          net: pros.settings.net,
        ),
        force: true);
  }
  for (final Security security in securities) {
    await pros.securities.save(
        Security.from(
          security,
          chain: pros.settings.chain,
          net: pros.settings.net,
        ),
        force: true);
  }
  for (final Metadata metadata in metadatas) {
    await pros.metadatas.save(
        Metadata.from(
          metadata,
          chain: pros.settings.chain,
          net: pros.settings.net,
        ),
        force: true);
  }
  for (final Unspent unspent in unspents) {
    await pros.unspents.save(
        Unspent.from(
          unspent,
          chain: pros.settings.chain,
          net: pros.settings.net,
        ),
        force: true);
  }
}

Future<List<String>> get getSecret async {
  final Wallet wallet = Current.wallet;
  if (wallet is LeaderWallet) {
    return (await wallet.mnemonic).split(' ');
  }
  if (wallet is SingleWallet) {
    return ((await wallet.kpWallet).privKey ?? '').split(' ');
  }
  return (await Current.wallet.secret(Current.wallet.cipher!)).split(' ');
}

/// mostly for illustrative purposes
Future<String?> get getCurrentXpub async =>
    (await services.wallet.leader.getSeedWallet(Current.wallet as LeaderWallet))
        .wallet
        .base58;
Future<BIP32> get rootNode async =>
    BIP32.fromBase58(await getCurrentXpub ?? '');
