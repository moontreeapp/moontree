import 'package:moontree_utils/moontree_utils.dart' show ToStringMixin;
import 'package:wallet_utils/wallet_utils.dart' as wu;

/* Unused
class NFTCreateRequest {
  late String name;
  late String ipfs;
  late String parent; // you have to use the wallet that holds the prent

  NFTCreateRequest({
    required this.name,
    required this.ipfs,
    required this.parent,
  });
}

class ChannelCreateRequest {
  late String name;
  late String ipfs;
  late String parent; // you have to use the wallet that holds the prent

  ChannelCreateRequest({
    required this.name,
    required this.ipfs,
    required this.parent,
  });
}

class QualifierCreateRequest {
  late String name;
  late String ipfs;
  late String quantity;
  late String parent; // you have to use the wallet that holds the prent

  QualifierCreateRequest({
    required this.name,
    required this.quantity,
    required this.ipfs,
    required this.parent,
  });
}

class MainCreateRequest {
  late String name;
  late String ipfs;
  late int quantity;
  late int decimals;
  late bool reissuable;
  late String?
      parent; // you have to use the wallet that holds the prent if sub asset

  MainCreateRequest({
    required this.name,
    required this.ipfs,
    required this.quantity,
    required this.decimals,
    required this.reissuable,
    this.parent,
  });
}

class RestrictedCreateRequest {
  late String name;
  late String ipfs;
  late int quantity;
  late int decimals;
  late String verifier;
  late bool reissuable;

  RestrictedCreateRequest({
    required this.name,
    required this.ipfs,
    required this.quantity,
    required this.decimals,
    required this.verifier,
    required this.reissuable,
  });
}
*/

//class GenericCreateRequest with ToStringMixin {
//  // you have to use the wallet that holds the prent if sub asset
//
//  GenericCreateRequest({
//    required this.isSub,
//    required this.isMain,
//    required this.isNFT,
//    required this.isChannel,
//    required this.isQualifier,
//    required this.isRestricted,
//    required this.name,
//    required this.fullName,
//    required this.wallet,
//    this.assetData,
//    this.quantity,
//    this.decimals,
//    this.verifier,
//    this.reissuable,
//    this.parent,
//  });
//  late bool isSub;
//  late bool isMain;
//  late bool isNFT;
//  late bool isChannel;
//  late bool isQualifier;
//  late bool isRestricted;
//  late String fullName;
//  late Wallet wallet;
//  late String name;
//  late double? quantity;
//  late Uint8List? assetData;
//  late int? decimals;
//  late String? verifier;
//  late bool? reissuable;
//  late String? parent;
//
//  @override
//  List<Object?> get props => <Object?>[
//        isSub,
//        isMain,
//        isNFT,
//        isChannel,
//        isQualifier,
//        isRestricted,
//        fullName,
//        wallet,
//        name,
//        assetData,
//        quantity,
//        decimals,
//        verifier,
//        reissuable,
//        parent,
//      ];
//  @override
//  List<String> get propNames => <String>[
//        'isSub',
//        'isMain',
//        'isNFT',
//        'isChannel',
//        'isQualifier',
//        'isRestricted',
//        'fullName',
//        'wallet',
//        'name',
//        'ipfs',
//        'quantity',
//        'decimals',
//        'verifier',
//        'reissuable',
//        'parent',
//      ];
//
//  Security get security => Security(
//        symbol: fullName,
//        chain: pros.settings.chain,
//        net: pros.settings.net,
//      );
//}
//
//class GenericReissueRequest with ToStringMixin {
//  // you have to use the wallet that holds the prent if sub asset
//
//  GenericReissueRequest({
//    required this.isSub,
//    required this.isMain,
//    required this.isRestricted,
//    required this.name,
//    required this.fullName,
//    required this.wallet,
//    required this.quantity,
//    required this.decimals,
//    required this.originalQuantity,
//    required this.originalDecimals,
//    required this.originalAssetData,
//    this.assetData,
//    this.verifier,
//    this.reissuable,
//    this.parent,
//  });
//  late bool isSub;
//  late bool isMain;
//  late bool isRestricted;
//  late String fullName;
//  late Wallet wallet;
//  late String name;
//  late double? quantity;
//  late int? decimals;
//  late double? originalQuantity;
//  late int? originalDecimals;
//  late Uint8List? originalAssetData;
//  late Uint8List? assetData;
//  late String? verifier;
//  late bool? reissuable;
//  late String? parent;
//
//  @override
//  List<Object?> get props => <Object?>[
//        isSub,
//        isMain,
//        isRestricted,
//        fullName,
//        wallet,
//        name,
//        quantity,
//        decimals,
//        originalQuantity,
//        originalDecimals,
//        originalAssetData,
//        assetData,
//        verifier,
//        reissuable,
//        parent,
//      ];
//  @override
//  List<String> get propNames => <String>[
//        'isSub',
//        'isMain',
//        'isRestricted',
//        'fullName',
//        'wallet',
//        'name',
//        'quantity',
//        'decimals',
//        'originalQuantity',
//        'originalDecimals',
//        'originalIpfs',
//        'ipfs',
//        'verifier',
//        'reissuable',
//        'parent',
//      ];
//
//  Security get security => Security(
//        symbol: fullName,
//        chain: pros.settings.chain,
//        net: pros.settings.net,
//      );
//}
//

/// we need to replace the wallet and security concepts with our own domain concepts
class SendRequest with ToStringMixin {
  SendRequest({
    required this.sendAll,
    required this.sendAddress,
    required this.holding,
    required this.visibleAmount,
    required this.sendAmountAsSats,
    feeRate,
    //required this.wallet,
    //this.security,
    this.assetMemo,
    this.memo,
    this.note,
  }) {
    this.feeRate = feeRate ?? wu.standardFee;
  }
  late bool sendAll;
  late String sendAddress;
  late double holding;
  late String visibleAmount;
  late int sendAmountAsSats;
  late wu.FeeRate feeRate;
  //late Wallet wallet;
  //late Security? security;
  late String? assetMemo;
  late String? memo;
  late String? note;

  @override
  List<Object> get props => <Object>[
        sendAll,
        sendAddress,
        holding,
        visibleAmount,
        sendAmountAsSats,
        feeRate,
        //wallet,
        //security ?? '?',
        assetMemo ?? '?',
        memo ?? '?',
        note ?? '?',
      ];
  @override
  List<String> get propNames => <String>[
        'sendAll',
        'sendAddress',
        'holding',
        'visibleAmount',
        'sendAmountAsSats',
        'feeRate',
        'wallet',
        'security',
        'assetMemo',
        'memo',
        'note',
      ];
}

//class SendEstimate with ToStringMixin {
//  SendEstimate(
//    this.amount, {
//    this.sendAll = false,
//    this.fees = 0,
//    List<Vout>? utxos,
//    this.security,
//    this.assetMemo,
//    this.memo,
//    this.creation = false,
//  }) : utxos = utxos ?? <Vout>[];
//
//  factory SendEstimate.copy(SendEstimate detail) {
//    return SendEstimate(detail.amount,
//        fees: detail.fees, utxos: detail.utxos.toList());
//  }
//
//  int amount; //sats
//  bool sendAll;
//  int fees;
//  List<Vout> utxos;
//  Security? security;
//  Uint8List? assetMemo;
//  String? memo;
//  int extraFees = 0;
//  bool creation;
//  int coinReturn = 0;
//
//  @override
//  List<Object?> get props => <Object?>[
//        amount,
//        fees,
//        utxos,
//        security,
//        assetMemo,
//        memo,
//        extraFees,
//        creation,
//      ];
//
//  @override
//  List<String> get propNames => <String>[
//        'amount',
//        'fees',
//        'utxos',
//        'security',
//        'assetMemo',
//        'memo',
//        'extraFees',
//        'creation',
//      ];
//
//  int get total => security == null || security == pros.securities.currentCoin
//      ? (creation ? 0 : amount) + fees + extraFees
//      : fees + extraFees;
//  int get utxoTotal => utxos.fold(
//      0, (int t, Vout vout) => t + vout.securityValue(security: security));
//  int get utxoCoinTotal =>
//      utxos.fold(0, (int running, Vout vout) => running + vout.coinValue);
//
//  int get changeDue => utxoTotal - total;
//
//  // expects the security to be null if crypto
//  int get inferredTransactionFee => security == null
//      ? utxoTotal - (amount + changeDue + extraFees)
//      : utxos.where((Vout e) => e.security == pros.securities.currentCoin).fold(
//              0,
//              (int total, Vout vout) =>
//                  total +
//                  vout.securityValue(security: pros.securities.currentCoin)) -
//          coinReturn;
//
//  void setFees(int fees_) => fees = fees_;
//  void setCoinReturn(int coinReturn_) => coinReturn = coinReturn_;
//  void setExtraFees(int fees_) => extraFees = fees_;
//  void setCreation(bool creation_) => creation = creation_;
//  void setUTXOs(List<Vout> utxos_) => utxos = utxos_;
//  void setAmount(int amount_) => amount = amount_;
//}
