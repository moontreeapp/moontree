import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/exposure.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show HDWallet, KPWallet, Network;

String makeEntropy({String? mnemonic}) =>
    bip39.mnemonicToEntropy(mnemonic ?? makeMnemonic());

String makeMnemonic({String? entropy}) => entropy == null
    ? bip39.generateMnemonic()
    : bip39.entropyToMnemonic(entropy);

Uint8List makeSeed([String? mnemonic]) =>
    bip39.mnemonicToSeed(mnemonic ?? makeMnemonic());

String makePubKey({Uint8List? seed, String? mnemonic}) =>
    HDWallet.fromSeed(seed ?? makeSeed(mnemonic)).pubKey;

/// a derived wallet
/// mnemonic we can derive a seed or entropy
/// from a mnemonic we can derive a seed or entropy
class Wallet {
  final String mnemonic;
  String? _pubkey;
  String? _entropy;
  Uint8List? _seed;
  Map<Blockchain, HDWallet> _hdWallets = {};

  Wallet({required this.mnemonic});

  HDWallet hdWallet(Blockchain blockchain) {
    _hdWallets[blockchain] ??=
        HDWallet.fromSeed(seed, network: blockchain.network);
    return _hdWallets[blockchain]!;
  }

  Uint8List get seed {
    _seed ??= bip39.mnemonicToSeed(mnemonic);
    return _seed!;
  }

  /// aren't pubkeys the same across networks?
  String? pubkey() {
    _pubkey ??= _hdWallets.values.firstOrNull?.pubKey;
    return _pubkey!;
  }

  String get entropy {
    _entropy ??= bip39.mnemonicToEntropy(mnemonic);
    return _entropy!;
  }
}

/// perhaps DerivedWallet shouldn't implement Wallet, but instead be a
/// slimmed down const address object or something?
class DerivedWallet extends Wallet {
  DerivedWallet({required super.mnemonic});
}

class SingleSelfWallet {
  String wif;

  SingleSelfWallet(this.wif);

  KPWallet wallet(Blockchain blockchain) {
    return KPWallet.fromWIF(wif, blockchain.network);
  }
}
