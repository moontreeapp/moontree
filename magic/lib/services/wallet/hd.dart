import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/derivation.dart';
import 'package:magic/domain/blockchain/exposure.dart';
import 'package:magic/domain/blockchain/net.dart';
import 'package:wallet_utils/wallet_utils.dart' show HDWallet, KPWallet;

String makeMnemonic({String? entropy}) => entropy == null
    ? bip39.generateMnemonic()
    : bip39.entropyToMnemonic(entropy);

String makeEntropy({String? mnemonic}) =>
    bip39.mnemonicToEntropy(mnemonic ?? makeMnemonic());

Uint8List makeSeed([String? mnemonic]) =>
    bip39.mnemonicToSeed(mnemonic ?? makeMnemonic());

String makePubKey({Uint8List? seed, String? mnemonic}) =>
    HDWallet.fromSeed(seed ?? makeSeed(mnemonic)).pubKey;

class SeedWallet {
  final Blockchain blockchain;
  final HDWallet hdWallet;
  final Map<String, HDWallet> subwalletsByPath = {};
  final Map<Exposure, int> highestIndex = {};
  final Map<Exposure, int> gap = {};

  SeedWallet({required this.blockchain, required this.hdWallet});

  HDWallet subwallet({
    required int hdIndex,
    Exposure exposure = Exposure.external,
  }) {
    final path = getDerivationPath(
      index: hdIndex,
      exposure: exposure,
      blockchain: blockchain,
    );
    print('p: $path');
    subwalletsByPath[path] ??= hdWallet.derivePath(path);
    return subwalletsByPath[path]!;
  }

  bool derive() {
    for (final exposure in Exposure.values) {
      highestIndex[exposure] ??= 0;
      gap[exposure] ??= 0;

      /// the server tells us the highest index right, so we know how far to go?
      /// how do we know the gap?
      //while (gap[exposure]! < 20) {
      //  subwallet(hdIndex: highestIndex[exposure]!+1, exposure: exposure);
      //  highestIndex[exposure] = highestIndex[exposure]! + 1;
      //  if empty {
      //    gap[exposure]! += 1;
      //  } else {
      //    gap[exposure]! = 0;
      //  }
      //}

      /// for now: just derive 20 addresses
      while (gap[exposure]! < 20) {
        subwallet(hdIndex: highestIndex[exposure]! + 1, exposure: exposure);
        highestIndex[exposure] = highestIndex[exposure]! + 1;
        gap[exposure] = gap[exposure]! + 1;
      }
    }
    return true;
  }
}

class Wallet {
  final String mnemonic;
  String? _pubkey;
  String? _entropy;
  Uint8List? _seed;
  final Map<Net, SeedWallet> subwallets = {};

  Wallet({required this.mnemonic});

  String get entropy {
    _entropy ??= bip39.mnemonicToEntropy(mnemonic);
    return _entropy!;
  }

  Uint8List get seed {
    _seed ??= bip39.mnemonicToSeed(mnemonic);
    return _seed!;
  }

  /// aren't pubkeys the same across networks?
  String? pubkey() {
    _pubkey ??= subwallets.values.firstOrNull?.hdWallet.pubKey;
    return _pubkey!;
  }

  HDWallet subwallet(Blockchain blockchain) {
    subwallets[blockchain.net] ??= SeedWallet(
        blockchain: blockchain,
        hdWallet: HDWallet.fromSeed(seed, network: blockchain.network));
    return subwallets[blockchain.net]!.hdWallet;
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
