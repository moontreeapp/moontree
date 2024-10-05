/* diagram
  cubits.keys.master (MasterWallet)
    can have multiple .keypairWallets (KeypairWallets)
      has one .wif
      can have one .wallets (KPWallet) per blockchain
        has one .address / .h160 / .pubkey / etc
    can have mulitple .derivationWallets (DerivationWallets)
      can have one .seedWallets (SeedWallet) per blockchain
        has two .roots per SeedWallet (external and internal)
        has two lists of .subwallets (HDWallets) (externals and internals)
          has one address per HDWallet
*/
import 'dart:typed_data';
import 'dart:convert';
import 'package:bip32/bip32.dart' as bip32;
import 'package:convert/convert.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/pane/send/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/derivation.dart';
import 'package:magic/domain/blockchain/exposure.dart';
import 'package:magic/domain/concepts/address.dart';
import 'package:magic/domain/wallet/kpwallet.dart';
import 'package:magic/utils/log.dart';
import 'package:moontree_utils/moontree_utils.dart' show decode;
import 'package:wallet_utils/wallet_utils.dart'
    show ECPair, HDWallet, KPWallet, NetworkType, P2PKH, WalletBase;

abstract class Jsonable {
  Map<String, dynamic> get asMap;
  String get asJson => jsonEncode(asMap);
}

class MasterWallet extends Jsonable {
  final List<DerivationWallet> derivationWallets = [];
  final List<KeypairWallet> keypairWallets = [];

  MasterWallet({
    Iterable<DerivationWallet>? derivationWallets,
    Iterable<KeypairWallet>? keypairWallets,
  }) {
    if (derivationWallets != null) {
      this.derivationWallets.addAll(derivationWallets);
    }
    if (keypairWallets != null) {
      this.keypairWallets.addAll(keypairWallets);
    }
  }

  factory MasterWallet.fromJson(String json) {
    final Map<String, List<String>> decoded = jsonDecode(json);
    return MasterWallet(
      derivationWallets: (decoded['derivationWallets'] ?? [])
          .map((mw) => DerivationWallet.fromJson(mw)),
      keypairWallets: (decoded['keypairWallets'] ?? [])
          .map((kp) => KeypairWallet.fromJson(kp)),
    );
  }

  @override
  Map<String, dynamic> get asMap => {
        'derivationWallets': derivationWallets.map((m) => m.asMap).toList(),
        'keypairWallets': keypairWallets.map((m) => m.asMap).toList(),
      };

  //Set<String> get xPubAddresses => (xPubWallets.expand((m) => m
  //    .seedWallet.subwallets.values
  //    .expand((subList) => subList.map((sub) => sub.address ?? '')))).toSet();

  Set<String> get derivationRoots => (derivationWallets
      .expand((m) => m.asRootXPubMap.values.expand((r) => r.values))
      .toSet());

  Set<String> get derivationAddresses => (derivationWallets
      .expand((m) => m.seedWallets.values.expand((s) => s.subwallets.values
          .expand((subList) => subList.map((sub) => sub.address ?? ''))))
      .toSet());

  Set<String> get keypairAddresses => keypairWallets
      .expand((kp) => kp.wallets.values.map((wallet) => wallet.address ?? ''))
      .toSet();

  Set<String> get addressSet => {...derivationAddresses, ...keypairAddresses};

  Set<String> get derivationScripthashes => derivationWallets
      .expand((derivationWallet) =>
          derivationWallet.seedWallets.entries.expand((entry) {
            final blockchain = entry.key;
            final seedWallet = entry.value;
            return seedWallet.subwallets.values.expand((subList) {
              return subList.map((subwallet) {
                final pubKey = subwallet.pubKey;
                return blockchain.scripthash(pubKey);
              });
            });
          }))
      .where((scripthash) => scripthash.isNotEmpty)
      .toSet();

  Set<String> get keypairScripthashes => keypairWallets
      .expand((kp) => kp.wallets.entries
          .map((entry) => entry.key.scripthash(entry.value.pubKey!)))
      .toSet();

  Set<String> get scripthashes =>
      {...derivationScripthashes, ...keypairScripthashes};

  Set<String> derivationScripthashesForBlockchain(Blockchain blockchain) =>
      derivationWallets
          .expand((derivationWallet) => derivationWallet.seedWallets.entries
                  .where((entry) => entry.key == blockchain)
                  .expand((entry) {
                final seedWallet = entry.value;
                return seedWallet.subwallets.values.expand((subList) {
                  return subList.map((subwallet) {
                    final pubKey = subwallet.pubKey;
                    return blockchain.scripthash(pubKey);
                  });
                });
              }))
          .where((scripthash) => scripthash.isNotEmpty)
          .toSet();

  Set<String> keypairScripthashesForBlockchain(Blockchain blockchain) =>
      keypairWallets
          .expand((kp) => kp.wallets.entries
              .where((entry) => entry.key == blockchain)
              .map((entry) => entry.key.scripthash(entry.value.pubKey!)))
          .toSet();

  Set<String> scripthashesForBlockchain(Blockchain blockchain) => {
        ...derivationScripthashesForBlockchain(blockchain),
        ...keypairScripthashesForBlockchain(blockchain)
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

  factory KeypairWallet.fromRoots(Map<String, String> rootXpubs) {
    final wallet = KeypairWallet(wif: '');
    rootXpubs.forEach((blockchainName, xpub) {
      final blockchain = Blockchain.from(name: blockchainName);
      wallet.wallets[blockchain] ??=
          keypairWalletFromPubKey(xpub, blockchain.network);
    });
    return wallet;
  }

  @override
  Map<String, String> get asMap => {'wif': wif};
  Map<String, String> get asRootXPubMap => {
        for (final w in wallets.entries)
          if (w.value.pubKey != null) w.key.name: w.value.pubKey!
      };

  static String privateKeyToWif(String privKey) =>
      ECPair.fromPrivateKey(decode(privKey)).toWIF();

  String address(Blockchain blockchain) => wallet(blockchain).address!;

  /// returns the address representation according to chain and net
  //String address(Chain chain, Net net, {bool isP2sh = false}) => h160ToAddress(
  //    h160: h160,
  //    addressType: isP2sh
  //        ? ChainNet(chain, net).chaindata.p2shPrefix
  //        : ChainNet(chain, net).chaindata.p2pkhPrefix);

  String h160Raw(Blockchain blockchain) => wallet(blockchain).pubKey!;
  ByteData h160RawBytes(Blockchain blockchain) =>
      hexStringToByteData(wallet(blockchain).pubKey!);
  Uint8List h160(Blockchain blockchain) =>
      hash160FromHexString(wallet(blockchain).pubKey!);
  String h160AsString(Blockchain blockchain) => hex.encode(h160(blockchain));
  ByteData h160AsByteData(Blockchain blockchain) =>
      hexStringToByteData(h160AsString(blockchain));
  //h160(blockchain).buffer.asByteData();
}

String hexStringToByteString(String hexString) {
  // Convert the hex string to a list of bytes
  List<int> bytes = hex.decode(hexString);

  // Convert each byte to the '\x' format
  String byteString =
      bytes.map((b) => '\\x${b.toRadixString(16).padLeft(2, '0')}').join('');

  return byteString;
}

ByteData hexStringToByteData(String hexString) {
  // Convert the hex string into a list of bytes
  List<int> bytes = hex.decode(hexString);

  // Create a ByteData from the list of bytes
  Uint8List uint8list = Uint8List.fromList(bytes);
  ByteData byteData = ByteData.sublistView(uint8list);

  return byteData;
}

/// An hd wallet that can derive multiple SeedWallet for different blockchains
class DerivationWallet extends Jsonable {
  final String? mnemonic;
  String? _entropy;
  Uint8List? _seed;
  Map<String, String>? xpubs;
  // (m/44'/coin_type'/account'/change/address_index) roots are change level?
  final Map<Blockchain, SeedWallet> seedWallets = {};
  final Map<Blockchain, Map<Exposure, String>> rootXpubs = {};
  final Map<Blockchain, Map<Exposure, int>> maxIds = {};
  DerivationWallet({this.mnemonic, this.xpubs});

  factory DerivationWallet.fromXpubs(Map<String, String> xpubs) {
    final wallet = DerivationWallet(xpubs: xpubs);
    xpubs.forEach((blockchainName, xpub) {
      final blockchain = Blockchain.from(name: blockchainName);
      wallet.seedWallets[blockchain] = SeedWallet(
        blockchain: blockchain,
        hdWallet: HDWallet.fromBase58(xpub, network: blockchain.network),
      );
    });
    return wallet;
  }
  factory DerivationWallet.fromRoots(
      Map<String, Map<String, String>> rootXpubs) {
    final wallet = DerivationWallet();
    rootXpubs.forEach((blockchainName, m) {
      final blockchain = Blockchain.from(name: blockchainName);
      m.forEach((exposureInt, xpub) {
        final exposure = Exposure.from(name: exposureInt);
        wallet.rootXpubs[blockchain] ??= {};
        if (wallet.rootXpubs[blockchain]![exposure] != null) {
          throw Exception(
              'duplicate root xpubs for $blockchainName $exposureInt');
        }
        wallet.rootXpubs[blockchain]![exposure] = xpub;
      });
    });
    return wallet;
  }

  factory DerivationWallet.fromJson(String json) {
    final Map<String, String> decoded = jsonDecode(json);
    return DerivationWallet(mnemonic: decoded['mnemonic']!);
  }

  @override
  Map<String, String> get asMap => mnemonic == null ? asXPubMap : asMnemonicMap;
  Map<String, String> get asMnemonicMap => {'mnemonic': mnemonic!};
  Map<String, String> get asXPubMap =>
      {for (final bs in seedWallets.entries) bs.key.name: bs.value.xpub};
  Map<String, Map<String, String>> get asRootXPubMap => {
        for (final ber in rootXpubs.entries)
          ber.key.name: {
            for (final er in ber.value.entries) er.key.name: er.value
          }
      };

  bool get cold => mnemonic == null;
  bool get hot => mnemonic != null;

  String get entropy {
    _entropy ??= bip39.mnemonicToEntropy(mnemonic);
    return _entropy!;
  }

  Uint8List get seed {
    _seed ??= bip39.mnemonicToSeed(mnemonic!);
    return _seed!;
  }

  List<String> get words => mnemonic?.split(' ') ?? [];

  // Deriving the private key from the mnemonic
  String get parentPrivateKey {
    // Generate the HD wallet root from the seed
    final root = bip32.BIP32.fromSeed(seed);
    // Get the private key in hex format (from the root node)
    // Returns Uint8List, convert to String as necessary
    return _bytesToHex(root.privateKey!);
  }

  // Helper function to convert Uint8List to hex
  String _bytesToHex(Uint8List bytes) {
    return hex.encode(bytes);
  }

  // /// this can derive neutered wallets. which, as it turns out are not all that
  // /// useful to us...
  // String? xpub(Blockchain blockchain) => seedWallet(blockchain).xpub;
  //
  // /// this is the compressed version of the xpub. not very useful in HD context.
  // String? pubkey(Blockchain blockchain) {
  //   //see('${blockchain.name} - ${seedWallet(blockchain).xpub}');
  //   //see('${blockchain.name} - ${seedWallet(blockchain).hdWallet.pubKey}');
  //   //see(
  //   //    '${blockchain.name} - ${seedWallet(blockchain).root(Exposure.external)} - external');
  //   //see(
  //   //    '${blockchain.name} - ${seedWallet(blockchain).root(Exposure.internal)} - internal');
  //   //Ravencoin - xpub661My...
  //   //Ravencoin - 0379c9413...
  //   //Ravencoin - xpub6EyL2...
  //   //Ravencoin - xpub6EyL2...
  //   //Evrmore   - xpub661My...
  //   //Evrmore   - 0379c9413...
  //   //Evrmore   - xpub6EyL2...
  //   //Evrmore   - xpub6EyL2...
  //   return seedWallet(blockchain).hdWallet.pubKey;
  // }

  SeedWallet seedWallet(Blockchain blockchain) {
    seedWallets[blockchain] ??= SeedWallet(
        blockchain: blockchain,
        hdWallet: HDWallet.fromSeed(seed, network: blockchain.network));
    //hdWallet: mnemonic != null
    //  ? HDWallet.fromSeed(seed, network: blockchain.network)
    //   : // always non-hardened, but never ran b/c rootXpubs is always set
    //    HDWallet.fromBase58(xpubs![blockchain.name]!, network: blockchain.network));
    return seedWallets[blockchain]!;
  }

  Map<Exposure, String> rootsMap(Blockchain blockchain) {
    rootXpubs[blockchain] ??= {
      Exposure.external: seedWallet(blockchain).root(Exposure.external),
      Exposure.internal: seedWallet(blockchain).root(Exposure.internal),
    };
    return rootXpubs[blockchain]!;
  }

  void addMaxId(Blockchain blockchain, Exposure exposure, int maxId) {
    if (maxIds[blockchain] == null) {
      maxIds[blockchain] = {};
    }
    maxIds[blockchain]![exposure] = maxId;
  }

  List<String> roots(Blockchain blockchain) =>
      rootsMap(blockchain).values.toList();

  String root(Blockchain blockchain, Exposure exposure) =>
      rootsMap(blockchain)[exposure]!;
}

/// add the hdIndex variable to the HDWallet class
class HDWalletIndexed extends HDWallet {
  final Blockchain blockchain;
  final Exposure exposure;
  final int hdIndex;
  final HDWallet hdWallet;

  HDWalletIndexed({
    required this.hdWallet,
    required this.blockchain,
    required this.exposure,
    required this.hdIndex,
  }) : super(
            bip32:
                HDWalletIndexed.fromBase58(hdWallet.base58!, hdWallet.network),
            p2pkh: hdWallet.p2pkh,
            network: hdWallet.network);

  static bip32.BIP32 fromBase58(String base58, NetworkType network) {
    return bip32.BIP32.fromBase58(
        base58,
        bip32.NetworkType(
            bip32: bip32.Bip32Type(
                public: network.bip32.public, private: network.bip32.private),
            wif: network.wif));
  }
}

class SeedWallet {
  final Blockchain blockchain;
  final HDWallet hdWallet;
  String? _xpub;
  final Map<Exposure, List<HDWallet>> subwallets = {
    Exposure.external: [],
    Exposure.internal: [],
  };
  final Map<Blockchain, Map<Exposure, Map<int, HDWallet>>> subwalletsIndexed = {
    Blockchain.evrmoreMain: {Exposure.external: {}, Exposure.internal: {}},
    Blockchain.evrmoreTest: {Exposure.external: {}, Exposure.internal: {}},
    Blockchain.ravencoinMain: {Exposure.external: {}, Exposure.internal: {}},
    Blockchain.ravencoinTest: {Exposure.external: {}, Exposure.internal: {}},
  };
  final Map<Exposure, int> highestIndex = {};
  final Map<Exposure, int> gap = {};

  SeedWallet({required this.blockchain, required this.hdWallet});

  String get xpub => extendedPublicKey;
  String get extendedPublicKey =>
      _xpub ??
      () {
        _xpub = hdWallet.base58;
        return _xpub!;
      }();

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
      hardened: hdWallet.seed != null ? "'" : '',
    );
    see('p: $path');
    final sub = hdWallet.derivePath(path);
    final indexedSub = HDWalletIndexed(
        hdWallet: sub,
        blockchain: blockchain,
        exposure: exposure,
        hdIndex: hdIndex);
    subwallets[exposure]!.add(indexedSub);
    return sub;
  }

  Future<bool> derive([Map<Exposure, int>? nextIndexByExposure]) async {
    nextIndexByExposure = nextIndexByExposure ??
        {
          Exposure.external: 0,
          Exposure.internal: 0,
        };
    for (final exposure in nextIndexByExposure.keys) {
      highestIndex[exposure] ??= -1;
      while (highestIndex[exposure]! < nextIndexByExposure[exposure]!) {
        while (cubits.app.animating) {
          await Future.delayed(const Duration(milliseconds: 1000));
        }
        see('subwalleting');
        subwallet(hdIndex: highestIndex[exposure]! + 1, exposure: exposure);
        highestIndex[exposure] = highestIndex[exposure]! + 1;
        // Yield control back to the UI thread
        await Future.delayed(Duration.zero);
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
          hardened: hdWallet.seed != null ? "'" : '',
        ),
      )
      .base58!;
}
