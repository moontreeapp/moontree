import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/derivation.dart';
import 'package:magic/domain/blockchain/exposure.dart';
import 'package:wallet_utils/wallet_utils.dart' show HDWallet, KPWallet;

class MasterWallet {
  final List<MnemonicWallet> mnemonicWallets = [];
  final List<KeypairWallet> keypairWallets = [];

  MasterWallet();
}

class KeypairWallet {
  String wif;

  KeypairWallet(this.wif);

  KPWallet wallet(Blockchain blockchain) {
    return KPWallet.fromWIF(wif, blockchain.network);
  }
}

/// An hd wallet that can derive multiple SeedWallet for different blockchains
class MnemonicWallet {
  final String mnemonic;
  String? _entropy;
  Uint8List? _seed;
  final Map<Blockchain, List<String>> _roots = {};
  final Map<Blockchain, SeedWallet> seedWallets = {};

  MnemonicWallet({required this.mnemonic});

  String get entropy {
    _entropy ??= bip39.mnemonicToEntropy(mnemonic);
    return _entropy!;
  }

  Uint8List get seed {
    _seed ??= bip39.mnemonicToSeed(mnemonic);
    return _seed!;
  }

  SeedWallet seedWallet(Blockchain blockchain) {
    seedWallets[blockchain] ??= SeedWallet(
        blockchain: blockchain,
        hdWallet: HDWallet.fromSeed(seed, network: blockchain.network));
    return seedWallets[blockchain]!;
  }

  String? pubkey(Blockchain blockchain) =>
      seedWallet(blockchain).hdWallet.pubKey;

  List<String> roots(Blockchain blockchain) {
    _roots[blockchain] ??= [
      seedWallet(blockchain).root(Exposure.external),
      seedWallet(blockchain).root(Exposure.internal),
    ];
    return _roots[blockchain]!;
  }
}

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

  String root(Exposure exposure) => hdWallet
      .derivePath(
        // "m/44'/175'/0'/0" external
        // "m/44'/175'/0'/1" internal
        getDerivationPath(
          exposure: exposure,
          blockchain: blockchain,
        ),
      )
      .base58!;
}
