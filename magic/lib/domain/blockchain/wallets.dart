import 'dart:typed_data';
import 'dart:convert';
import 'package:bip39/bip39.dart' as bip39;
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/derivation.dart';
import 'package:magic/domain/blockchain/exposure.dart';
import 'package:wallet_utils/wallet_utils.dart' show HDWallet, KPWallet;

abstract class Jsonable {
  Map<String, dynamic> get asMap;
  String get asJson => jsonEncode(asMap);
}

/// this should be a cubit or something rather than a hierarchical object,
/// that introduces complexity with no value added.
class MasterWallet extends Jsonable {
  final List<MnemonicWallet> mnemonicWallets = [];
  final List<KeypairWallet> keypairWallets = [];

  MasterWallet({
    Iterable<MnemonicWallet>? mnemonicWallets,
    Iterable<KeypairWallet>? keypairWallets,
  }) {
    if (mnemonicWallets != null) {
      this.mnemonicWallets.addAll(mnemonicWallets);
    }
    if (keypairWallets != null) {
      this.keypairWallets.addAll(keypairWallets);
    }
  }

  factory MasterWallet.fromJson(String json) {
    final Map<String, List<String>> decoded = jsonDecode(json);
    return MasterWallet(
      mnemonicWallets: (decoded['mnemonicWallets'] ?? [])
          .map((mw) => MnemonicWallet.fromJson(mw)),
      keypairWallets: (decoded['keypairWallets'] ?? [])
          .map((kp) => KeypairWallet.fromJson(kp)),
    );
  }

  @override
  Map<String, dynamic> get asMap => {
        'mnemonicWallets': mnemonicWallets.map((m) => m.asMap).toList(),
        'keypairWallets': keypairWallets.map((m) => m.asMap).toList(),
      };
}

class KeypairWallet extends Jsonable {
  final String wif;
  final Map<Blockchain, KPWallet> wallets = {};

  KeypairWallet({required this.wif});

  KPWallet wallet(Blockchain blockchain) {
    wallets[blockchain] ??= KPWallet.fromWIF(wif, blockchain.network);
    return wallets[blockchain]!;
  }

  factory KeypairWallet.fromJson(String json) {
    final Map<String, String> decoded = jsonDecode(json);
    return KeypairWallet(wif: decoded['wif']!);
  }

  @override
  Map<String, String> get asMap => {'wif': wif};
}

/// An hd wallet that can derive multiple SeedWallet for different blockchains
class MnemonicWallet extends Jsonable {
  final String mnemonic;
  String? _entropy;
  Uint8List? _seed;
  final Map<Blockchain, List<String>> _roots = {};
  final Map<Blockchain, SeedWallet> seedWallets = {};

  MnemonicWallet({required this.mnemonic});

  factory MnemonicWallet.fromJson(String json) {
    final Map<String, String> decoded = jsonDecode(json);
    return MnemonicWallet(mnemonic: decoded['mnemonic']!);
  }

  @override
  Map<String, String> get asMap => {'mnemonic': mnemonic};

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
