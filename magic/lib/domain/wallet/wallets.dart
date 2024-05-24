/* diagram
  cubits.keys.master (MasterWallet)
    can have multiple .keypairWallets (KeypairWallets)
      has one .wif
      can have one .wallets (KPWallet) per blockchain
        has one .address / .h160 / .pubkey / etc
    can have mulitple .mnemonicWallets (MnemonicWallets)
      can have one .seedWallets (SeedWallet) per blockchain
        has two .roots per SeedWallet (external and internal)
        has two lists of .subwallets (HDWallets) (externals and internals)
          has one address per HDWallet
*/
import 'dart:typed_data';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/derivation.dart';
import 'package:magic/domain/blockchain/exposure.dart';
import 'package:magic/domain/concepts/address.dart';
import 'package:wallet_utils/wallet_utils.dart' show HDWallet, KPWallet;

abstract class Jsonable {
  Map<String, dynamic> get asMap;
  String get asJson => jsonEncode(asMap);
}

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

  String address(Blockchain blockchain) => wallet(blockchain).address!;

  /// returns the address representation according to chain and net
  //String address(Chain chain, Net net, {bool isP2sh = false}) => h160ToAddress(
  //    h160: h160,
  //    addressType: isP2sh
  //        ? ChainNet(chain, net).chaindata.p2shPrefix
  //        : ChainNet(chain, net).chaindata.p2pkhPrefix);

  Uint8List h160(Blockchain blockchain) =>
      hash160FromHexString(wallet(blockchain).pubKey!);
  String h160AsString(Blockchain blockchain) => hex.encode(h160(blockchain));
  ByteData h160AsByteData(Blockchain blockchain) =>
      h160(blockchain).buffer.asByteData();
}

/// An hd wallet that can derive multiple SeedWallet for different blockchains
class MnemonicWallet extends Jsonable {
  final String mnemonic;
  String? _entropy;
  Uint8List? _seed;
  final Map<Blockchain, Map<Exposure, String>> _roots = {};
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

  Map<Exposure, String> rootsMap(Blockchain blockchain) {
    _roots[blockchain] ??= {
      Exposure.external: seedWallet(blockchain).root(Exposure.external),
      Exposure.internal: seedWallet(blockchain).root(Exposure.internal),
    };
    return _roots[blockchain]!;
  }

  List<String> roots(Blockchain blockchain) =>
      rootsMap(blockchain).values.toList();

  String root(Blockchain blockchain, Exposure exposure) =>
      rootsMap(blockchain)[exposure]!;
}

class SeedWallet {
  final Blockchain blockchain;
  final HDWallet hdWallet;
  final Map<Exposure, List<HDWallet>> subwallets = {
    Exposure.external: [],
    Exposure.internal: [],
  };
  final Map<Exposure, int> highestIndex = {};
  final Map<Exposure, int> gap = {};

  SeedWallet({required this.blockchain, required this.hdWallet});

  List<HDWallet> get externals => subwallets[Exposure.external]!;
  List<HDWallet> get internals => subwallets[Exposure.internal]!;

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
    final sub = hdWallet.derivePath(path);
    subwallets[exposure]!.add(sub);
    return sub;
  }

  bool derive([Map<Exposure, int>? nextIndexByExposure]) {
    nextIndexByExposure = nextIndexByExposure ??
        {
          Exposure.external: 0,
          Exposure.internal: 0,
        };
    for (final exposure in nextIndexByExposure.keys) {
      highestIndex[exposure] ??= -1;
      gap[exposure] ??= 0; // this concept may be irrelevant
      while (gap[exposure]! < 20 &&
          highestIndex[exposure]! < nextIndexByExposure[exposure]!) {
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
