import 'dart:typed_data';
import 'package:tuple/tuple.dart';
import 'package:moontree_utils/moontree_utils.dart'
    show StringBytesExtension, ToStringMixin, amountToSat;
import 'package:wallet_utils/wallet_utils.dart' as wu;
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/transaction/sign.dart';

import 'verify.dart';

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

class GenericCreateRequest with ToStringMixin {
  // you have to use the wallet that holds the prent if sub asset

  GenericCreateRequest({
    required this.isSub,
    required this.isMain,
    required this.isNFT,
    required this.isChannel,
    required this.isQualifier,
    required this.isRestricted,
    required this.name,
    required this.fullName,
    required this.wallet,
    this.assetData,
    this.quantity,
    this.decimals,
    this.verifier,
    this.reissuable,
    this.parent,
  });
  late bool isSub;
  late bool isMain;
  late bool isNFT;
  late bool isChannel;
  late bool isQualifier;
  late bool isRestricted;
  late String fullName;
  late Wallet wallet;
  late String name;
  late double? quantity;
  late Uint8List? assetData;
  late int? decimals;
  late String? verifier;
  late bool? reissuable;
  late String? parent;

  @override
  List<Object?> get props => <Object?>[
        isSub,
        isMain,
        isNFT,
        isChannel,
        isQualifier,
        isRestricted,
        fullName,
        wallet,
        name,
        assetData,
        quantity,
        decimals,
        verifier,
        reissuable,
        parent,
      ];
  @override
  List<String> get propNames => <String>[
        'isSub',
        'isMain',
        'isNFT',
        'isChannel',
        'isQualifier',
        'isRestricted',
        'fullName',
        'wallet',
        'name',
        'ipfs',
        'quantity',
        'decimals',
        'verifier',
        'reissuable',
        'parent',
      ];

  Security get security => Security(
        symbol: fullName,
        chain: pros.settings.chain,
        net: pros.settings.net,
      );
}

class GenericReissueRequest with ToStringMixin {
  // you have to use the wallet that holds the prent if sub asset

  GenericReissueRequest({
    required this.isSub,
    required this.isMain,
    required this.isRestricted,
    required this.name,
    required this.fullName,
    required this.wallet,
    required this.quantity,
    required this.decimals,
    required this.originalQuantity,
    required this.originalDecimals,
    required this.originalAssetData,
    this.assetData,
    this.verifier,
    this.reissuable,
    this.parent,
  });
  late bool isSub;
  late bool isMain;
  late bool isRestricted;
  late String fullName;
  late Wallet wallet;
  late String name;
  late double? quantity;
  late int? decimals;
  late double? originalQuantity;
  late int? originalDecimals;
  late Uint8List? originalAssetData;
  late Uint8List? assetData;
  late String? verifier;
  late bool? reissuable;
  late String? parent;

  @override
  List<Object?> get props => <Object?>[
        isSub,
        isMain,
        isRestricted,
        fullName,
        wallet,
        name,
        quantity,
        decimals,
        originalQuantity,
        originalDecimals,
        originalAssetData,
        assetData,
        verifier,
        reissuable,
        parent,
      ];
  @override
  List<String> get propNames => <String>[
        'isSub',
        'isMain',
        'isRestricted',
        'fullName',
        'wallet',
        'name',
        'quantity',
        'decimals',
        'originalQuantity',
        'originalDecimals',
        'originalIpfs',
        'ipfs',
        'verifier',
        'reissuable',
        'parent',
      ];

  Security get security => Security(
        symbol: fullName,
        chain: pros.settings.chain,
        net: pros.settings.net,
      );
}

class SendRequest with ToStringMixin {
  SendRequest({
    required this.sendAll,
    required this.sendAddress,
    required this.holding,
    required this.visibleAmount,
    required this.sendAmountAsSats,
    required this.feeRate,
    required this.wallet,
    this.security,
    this.assetMemo,
    this.memo,
    this.note,
  });
  late bool sendAll;
  late String sendAddress;
  late double holding;
  late String visibleAmount;
  late int sendAmountAsSats;
  late wu.FeeRate feeRate;
  late Wallet wallet;
  late Security? security;
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
        wallet,
        security ?? '?',
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

class SendEstimate with ToStringMixin {
  SendEstimate(
    this.amount, {
    this.sendAll = false,
    this.fees = 0,
    List<Vout>? utxos,
    this.security,
    this.assetMemo,
    this.memo,
    this.creation = false,
  }) : utxos = utxos ?? <Vout>[];

  factory SendEstimate.copy(SendEstimate detail) {
    return SendEstimate(detail.amount,
        fees: detail.fees, utxos: detail.utxos.toList());
  }

  int amount; //sats
  bool sendAll;
  int fees;
  List<Vout> utxos;
  Security? security;
  Uint8List? assetMemo;
  String? memo;
  int extraFees = 0;
  bool creation;
  int coinReturn = 0;

  @override
  List<Object?> get props => <Object?>[
        amount,
        fees,
        utxos,
        security,
        assetMemo,
        memo,
        extraFees,
        creation,
      ];

  @override
  List<String> get propNames => <String>[
        'amount',
        'fees',
        'utxos',
        'security',
        'assetMemo',
        'memo',
        'extraFees',
        'creation',
      ];

  int get total => security == null || security == pros.securities.currentCoin
      ? (creation ? 0 : amount) + fees + extraFees
      : fees + extraFees;
  int get utxoTotal => utxos.fold(
      0, (int t, Vout vout) => t + vout.securityValue(security: security));
  int get utxoCoinTotal =>
      utxos.fold(0, (int running, Vout vout) => running + vout.coinValue);

  int get changeDue => utxoTotal - total;

  // expects the security to be null if crypto
  int get inferredTransactionFee => security == null
      ? utxoTotal - (amount + changeDue + extraFees)
      : utxos.where((Vout e) => e.security == pros.securities.currentCoin).fold(
              0,
              (int total, Vout vout) =>
                  total +
                  vout.securityValue(security: pros.securities.currentCoin)) -
          coinReturn;

  void setFees(int fees_) => fees = fees_;
  void setCoinReturn(int coinReturn_) => coinReturn = coinReturn_;
  void setExtraFees(int fees_) => extraFees = fees_;
  void setCreation(bool creation_) => creation = creation_;
  void setUTXOs(List<Vout> utxos_) => utxos = utxos_;
  void setAmount(int amount_) => amount = amount_;
}

class TransactionMaker {
  Future<Tuple2<wu.Transaction, SendEstimate>> transactionBy(
    SendRequest sendRequest,
  ) async {
    final SendEstimate estimate = SendEstimate(
      sendRequest.sendAmountAsSats,
      sendAll: sendRequest.sendAll,
      security: sendRequest.security == pros.securities.currentCoin
          ? null
          : sendRequest.security,
      assetMemo: sendRequest.assetMemo?.base58Decode,
      memo: sendRequest.memo,
    );

    return (sendRequest.sendAll ||
                sendRequest.sendAmountAsSats == sendRequest.holding.asSats) &&
            (sendRequest.security == null ||
                sendRequest.security == pros.securities.currentCoin)
        ? await transactionSendAllRVN(
            sendRequest.sendAddress,
            estimate,
            wallet: sendRequest.wallet,
            feeRate: sendRequest.feeRate,
            /*assetMemoExpiry: not captured yet*/
          )
        : await transaction(
            sendRequest.sendAddress,
            estimate,
            wallet: sendRequest.wallet,
            feeRate: sendRequest.feeRate,
            /*assetMemoExpiry: not captured yet*/
          );
  }

  Future<Tuple2<wu.Transaction, SendEstimate>> createTransactionBy(
    GenericCreateRequest createRequest,
  ) async {
    final SendEstimate estimate = SendEstimate(
      ((createRequest.quantity ?? 1) * wu.satsPerCoin).toInt(),
      security: createRequest.security,
      creation: true,
      //assetMemo: createRequest.assetMemo, // not on front end
      //memo: createRequest.memo, // op return memos allowed, but not on front end
    );
    return createRequest.isNFT || createRequest.isChannel
        ? await transactionCreateChildAsset(
            createRequest.parent!,
            estimate,
            wallet: createRequest.wallet,
            ipfsData: createRequest.assetData,
            feeRate: wu.FeeRates.standard,
          )
        : createRequest.isSub
            ? await transactionCreateSubAsset(
                createRequest.parent!,
                estimate,
                createRequest.decimals ?? 0,
                createRequest.reissuable ?? false,
                wallet: createRequest.wallet,
                ipfsData: createRequest.assetData,
                feeRate: wu.FeeRates.standard,
              )
            :
            // Restricted and Qualifier
            await transactionCreateMainAsset(
                estimate,
                createRequest.decimals ?? 0,
                createRequest.reissuable ?? false,
                wallet: createRequest.wallet,
                ipfsData: createRequest.assetData,
                feeRate: wu.FeeRates.standard,
              );
  }

  Future<Tuple2<wu.Transaction, SendEstimate>> reissueTransactionBy(
    GenericReissueRequest reissueRequest,
  ) async {
    final SendEstimate estimate = SendEstimate(
      ((reissueRequest.quantity ?? 0) * wu.satsPerCoin).toInt(),
      security: reissueRequest.security,
      creation: true,
    );
    return reissueRequest.isRestricted
        ? await transactionReissueRestrictedAsset(
            estimate,
            reissueRequest.originalDecimals ?? 0,
            (reissueRequest.originalQuantity! * wu.satsPerCoin).toInt(),
            reissueRequest.decimals ?? 0,
            reissueRequest.reissuable ?? false,
            wallet: reissueRequest.wallet,
            ipfsData:
                reissueRequest.assetData == reissueRequest.originalAssetData
                    ? null
                    : reissueRequest.assetData,
            feeRate: wu.FeeRates.standard)
        : await transactionReissueAsset(
            estimate,
            reissueRequest.originalDecimals ?? 0,
            (reissueRequest.originalQuantity! * wu.satsPerCoin).toInt(),
            reissueRequest.decimals ?? 0,
            reissueRequest.reissuable ?? false,
            wallet: reissueRequest.wallet,
            ipfsData:
                reissueRequest.assetData == reissueRequest.originalAssetData
                    ? null
                    : reissueRequest.assetData,
            feeRate: wu.FeeRates.standard);
  }

  Future<Tuple2<wu.Transaction, SendEstimate>> transactionCreateQualifier(
    SendEstimate estimate, {
    required Wallet wallet,
    Uint8List? ipfsData,
    wu.FeeRate? feeRate,
    String? newAssetToAddress,
  }) async {
    wu.TransactionBuilder? txb;
    wu.Transaction tx;

    if (estimate.amount > 10 * wu.satsPerCoin) {
      throw ArgumentError('Amount must be at most 10');
    }
    if (estimate.security == null || estimate.security!.symbol[0] != '#') {
      throw ArgumentError('Asset must be a qualifying asset');
    }

    int feeSats = 0;
    List<Vout> utxosRaven = <Vout>[];
    final String returnAddress =
        services.wallet.getEmptyAddress(wallet, NodeExposure.internal);
    int returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = wu.TransactionBuilder(
        network: pros.settings.network,
        chainName: pros.settings.chain.name,
      );
      // Grab required RVN for fee + burn
      utxosRaven = await services.balance.collectUTXOs(
          walletId: wallet.id,
          amount: feeSats + pros.settings.network.burnAmounts.issueQualifier);
      int satsIn = 0;
      for (final Vout utxo in utxosRaven) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.coinValue;
      }
      returnRaven =
          satsIn - pros.settings.network.burnAmounts.issueQualifier - feeSats;

      txb.generateCreateQualifierVouts(newAssetToAddress ?? returnAddress,
          estimate.amount, estimate.security!.symbol, ipfsData);

      if (estimate.memo != null) {
        txb.addMemo(estimate.memo, offset: 1);
      }
      if (returnRaven > 0) {
        txb.addChangeToAssetCreationOrReissuance(1, returnAddress, returnRaven);
      }
      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: feeRate));
    }
    estimate.setCoinReturn(returnRaven);
    estimate.setExtraFees(pros.settings.network.burnAmounts.issueQualifier);
    await txb!.signEachInput(utxosRaven);
    tx = txb.build();
    return Tuple2<wu.Transaction, SendEstimate>(tx, estimate);
  }

  Future<Tuple2<wu.Transaction, SendEstimate>> transactionCreateSubQualifier(
    SendEstimate estimate,
    String parentAsset, {
    required Wallet wallet,
    Uint8List? ipfsData,
    wu.FeeRate? feeRate,
    String? newAssetToAddress,
    String? parentAssetToAddress,
  }) async {
    wu.TransactionBuilder? txb;
    wu.Transaction tx;

    if (estimate.amount > 10 * wu.satsPerCoin) {
      throw ArgumentError('Amount must be at most 10');
    }
    if (estimate.security == null || estimate.security!.symbol[0] != '#') {
      throw ArgumentError('Asset must be a qualifying asset');
    }
    int feeSats = 0;
    // Grab required assets for transfer amount
    List<Vout> utxosRaven = <Vout>[];
    // 1 parent qualifier asset, may have leftover
    final List<Vout> utxosSecurity = !<Security?>[
      null,
      pros.securities.currentCoin
    ].contains(estimate.security)
        ? await services.balance.collectUTXOs(
            walletId: wallet.id,
            amount: wu.satsPerCoin,
            security: Security(
              symbol: parentAsset,
              chain: pros.settings.chain,
              net: pros.settings.net,
            ))
        : <Vout>[];
    int securityIn = 0;
    for (final Vout utxo in utxosSecurity) {
      securityIn += utxo.assetValue!;
    }
    final int securityChange = securityIn - wu.satsPerCoin;

    final String returnAddress =
        services.wallet.getEmptyAddress(wallet, NodeExposure.internal);
    int returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = wu.TransactionBuilder(
        network: pros.settings.network,
        chainName: pros.settings.chain.name,
      );
      // Grab required RVN for fee + burn
      utxosRaven = await services.balance.collectUTXOs(
        walletId: wallet.id,
        amount: feeSats + pros.settings.network.burnAmounts.issueSubQualifier,
      );
      int satsIn = 0;
      for (final Vout utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.coinValue;
      }
      returnRaven = satsIn -
          pros.settings.network.burnAmounts.issueSubQualifier -
          feeSats;
      txb.generateCreateSubQualifierVouts(
          newAssetToAddress ?? returnAddress,
          parentAssetToAddress ?? newAssetToAddress ?? returnAddress,
          estimate.amount,
          parentAsset,
          estimate.security!.symbol,
          ipfsData);
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo, offset: 1);
      }
      if (returnRaven > 0) {
        txb.addChangeToAssetCreationOrReissuance(1, returnAddress, returnRaven);
      }
      if (securityChange > 0) {
        txb.addChangeToAssetCreationOrReissuance(
            -1, returnAddress, securityChange,
            asset: parentAsset);
      }
      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: feeRate));
    }
    estimate.setCoinReturn(returnRaven);
    estimate.setExtraFees(pros.settings.network.burnAmounts.issueSubQualifier);
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2<wu.Transaction, SendEstimate>(tx, estimate);
  }

  Future<Tuple2<wu.Transaction, SendEstimate>> transactionCreateRestricted(
    SendEstimate estimate,
    int divisibility,
    bool reissuable, {
    required Wallet wallet,
    String? newAssetToAddress,
    String? parentAssetToAddress,
    Uint8List? ipfsData,
    String? verifier,
    wu.FeeRate? feeRate,
  }) async {
    wu.TransactionBuilder? txb;
    wu.Transaction tx;
    if (estimate.security == null || estimate.security!.symbol[0] != r'$') {
      throw ArgumentError('Asset must be a restricted asset');
    }
    int feeSats = 0;
    // Grab required assets for transfer amount
    List<Vout> utxosRaven = <Vout>[];
    // 1 virtual ownership asset for the parent
    final List<Vout> utxosSecurity = !<Security?>[
      null,
      pros.securities.currentCoin
    ].contains(estimate.security)
        ? await services.balance.collectUTXOs(
            walletId: wallet.id,
            amount: wu.satsPerCoin,
            security: Security(
              symbol: '${estimate.security!.symbol.substring(1)}!',
              chain: pros.settings.chain,
              net: pros.settings.net,
            ))
        : <Vout>[];
    final String returnAddress =
        services.wallet.getEmptyAddress(wallet, NodeExposure.internal);
    int returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = wu.TransactionBuilder(
        network: pros.settings.network,
        chainName: pros.settings.chain.name,
      );
      // Grab required RVN for fee + burn
      utxosRaven = await services.balance.collectUTXOs(
        walletId: wallet.id,
        amount: feeSats + pros.settings.network.burnAmounts.issueRestricted,
      );
      int satsIn = 0;
      for (final Vout utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.coinValue;
      }
      returnRaven =
          satsIn - pros.settings.network.burnAmounts.issueRestricted - feeSats;

      txb.generateCreateRestrictedVouts(
          newAssetToAddress ?? returnAddress,
          parentAssetToAddress ?? newAssetToAddress ?? returnAddress,
          estimate.amount,
          divisibility,
          reissuable,
          ipfsData,
          estimate.security!.symbol,
          verifier);

      if (estimate.memo != null) {
        txb.addMemo(estimate.memo, offset: 1);
      }
      if (returnRaven > 0) {
        txb.addChangeToAssetCreationOrReissuance(1, returnAddress, returnRaven);
      }
      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: feeRate));
    }
    estimate.setCoinReturn(returnRaven);
    estimate.setExtraFees(pros.settings.network.burnAmounts.issueRestricted);
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2<wu.Transaction, SendEstimate>(tx, estimate);
  }

  Future<Tuple2<wu.Transaction, SendEstimate>>
      transactionReissueRestrictedAsset(
    SendEstimate estimate,
    int originalDivisibility,
    int currentSatsInCirculation,
    int newDivisibility,
    bool reissuability, {
    required Wallet wallet,
    String? verifier,
    String? newAssetToAddress,
    String? ownershipToAddress,
    Uint8List? ipfsData,
    wu.FeeRate? feeRate,
  }) async {
    wu.TransactionBuilder? txb;
    wu.Transaction tx;

    if (estimate.security == null || estimate.security!.symbol[0] != r'$') {
      throw ArgumentError('Asset must be a restricted asset');
    }

    int feeSats = 0;
    // Grab required assets for transfer amount
    List<Vout> utxosRaven = <Vout>[];
    final List<Vout> utxosSecurity = await services.balance.collectUTXOs(
        walletId: wallet.id,
        amount: wu.satsPerCoin, // 1 virtual sat for ownership asset
        security: Security(
          symbol: '${estimate.security!.symbol.substring(1)}!',
          chain: pros.settings.chain,
          net: pros.settings.net,
        ));
    final String returnAddress =
        services.wallet.getEmptyAddress(wallet, NodeExposure.internal);
    int returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = wu.TransactionBuilder(
        network: pros.settings.network,
        chainName: pros.settings.chain.name,
      );
      // Grab required RVN for fee + burn amount
      utxosRaven = await services.balance.collectUTXOs(
        walletId: wallet.id,
        amount: feeSats + pros.settings.network.burnAmounts.reissue,
      );
      int satsIn = 0;
      for (final Vout utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.coinValue;
      }
      returnRaven =
          satsIn - pros.settings.network.burnAmounts.reissue - feeSats;

      // This populates the transaction with vouts for reissuing
      txb.generateReissueRestrictedVouts(
          newAssetToAddress ?? returnAddress,
          ownershipToAddress ?? newAssetToAddress ?? returnAddress,
          currentSatsInCirculation,
          estimate.amount,
          originalDivisibility,
          newDivisibility,
          reissuability,
          ipfsData,
          estimate.security!.symbol,
          verifier);

      // This inserts a memo in a valid index
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo, offset: 1);
      }
      // This inserts change in a valid index
      if (returnRaven > 0) {
        txb.addChangeToAssetCreationOrReissuance(1, returnAddress, returnRaven);
      }

      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: feeRate));
    }
    estimate.setCoinReturn(returnRaven);
    estimate.setExtraFees(pros.settings.network.burnAmounts.reissue);
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2<wu.Transaction, SendEstimate>(tx, estimate);
  }

  Future<Tuple2<wu.Transaction, SendEstimate>> transactionQualifyAddress(
    SendEstimate estimate,
    String qualifyingAsset,
    String addressToQualify,
    bool tag, {
    required Wallet wallet,
    String? qualifierToAddress,
    wu.FeeRate? feeRate,
  }) async {
    wu.TransactionBuilder? txb;
    wu.Transaction tx;
    if (estimate.security == null ||
        estimate.security!.symbol.contains(RegExp(r'^[\$#].*$'))) {
      throw ArgumentError('Asset must be a qualifier or a restricted asset');
    }
    int feeSats = 0;
    // Grab required assets for transfer amount
    List<Vout> utxosRaven = <Vout>[];
    final List<Vout> utxosSecurity = await services.balance.collectUTXOs(
        walletId: wallet.id,
        amount: wu.satsPerCoin, // 1 sat for ownership asset
        security: Security(
          symbol: estimate.security!.symbol[0] == r'$'
              ? '${estimate.security!.symbol.substring(1)}!'
              : estimate.security!.symbol,
          chain: pros.settings.chain,
          net: pros.settings.net,
        ));
    int securityIn = 0; // May be qualifier
    for (final Vout utxo in utxosSecurity) {
      securityIn += utxo.assetValue!;
    }
    final int securityChange = securityIn - wu.satsPerCoin;

    final String returnAddress =
        services.wallet.getEmptyAddress(wallet, NodeExposure.internal);
    int returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = wu.TransactionBuilder(
        network: pros.settings.network,
        chainName: pros.settings.chain.name,
      );
      // Grab required RVN for fee + burn amount
      utxosRaven = await services.balance.collectUTXOs(
        walletId: wallet.id,
        amount: feeSats + pros.settings.network.burnAmounts.addTag,
      );
      int satsIn = 0;
      for (final Vout utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.coinValue;
      }
      returnRaven = satsIn - pros.settings.network.burnAmounts.addTag - feeSats;

      // This populates the transaction with vouts for reissuing
      txb.generateQualifyAddressVouts(qualifierToAddress ?? returnAddress,
          estimate.security!.symbol, addressToQualify, tag);

      // This inserts a memo in a valid index
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo, offset: -1);
      }
      // This inserts change in a valid index
      if (returnRaven > 0) {
        txb.addChangeToAssetCreationOrReissuance(
            -1, returnAddress, returnRaven);
      }
      if (securityChange > 0) {
        txb.addChangeToAssetCreationOrReissuance(
            1, returnAddress, securityChange,
            asset: estimate.security!.symbol[0] == r'$'
                ? '${estimate.security!.symbol.substring(1)}!'
                : estimate.security!.symbol);
      }

      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: feeRate));
    }
    estimate.setCoinReturn(returnRaven);
    estimate.setExtraFees(pros.settings.network.burnAmounts.addTag);
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2<wu.Transaction, SendEstimate>(tx, estimate);
  }

  Future<Tuple2<wu.Transaction, SendEstimate>> transactionReissueAsset(
    SendEstimate estimate,
    int originalDivisibility,
    int currentSatsInCirculation,
    int newDivisibility,
    bool reissuability, {
    required Wallet wallet,
    String? newAssetToAddress,
    String? ownershipToAddress,
    Uint8List? ipfsData,
    wu.FeeRate? feeRate,
  }) async {
    wu.TransactionBuilder? txb;
    wu.Transaction tx;
    int feeSats = 0;
    // Grab required assets for transfer amount
    List<Vout> utxosRaven = <Vout>[];
    final List<Vout> utxosSecurity = await services.balance.collectUTXOs(
        walletId: wallet.id,
        amount: wu.satsPerCoin, // 1 virtual sat for ownership asset
        security: Security(
          symbol: '${estimate.security!.symbol}!',
          chain: pros.settings.chain,
          net: pros.settings.net,
        ));
    final String returnAddress =
        services.wallet.getEmptyAddress(wallet, NodeExposure.internal);
    int returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = wu.TransactionBuilder(
        network: pros.settings.network,
        chainName: pros.settings.chain.name,
      );
      // Grab required RVN for fee + burn amount
      utxosRaven = await services.balance.collectUTXOs(
        walletId: wallet.id,
        amount: feeSats + pros.settings.network.burnAmounts.reissue,
      );
      int satsIn = 0;
      for (final Vout utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.coinValue;
      }
      returnRaven =
          satsIn - pros.settings.network.burnAmounts.reissue - feeSats;

      // This populates the transaction with vouts for reissuing
      txb.generateCreateReissueVouts(
          newAssetToAddress ?? returnAddress,
          ownershipToAddress ?? newAssetToAddress ?? returnAddress,
          currentSatsInCirculation,
          estimate.amount,
          estimate.security!.symbol,
          originalDivisibility,
          newDivisibility,
          reissuability,
          ipfsData);

      // This inserts a memo in a valid index
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo, offset: 1);
      }
      // This inserts change in a valid index
      if (returnRaven > 0) {
        txb.addChangeToAssetCreationOrReissuance(1, returnAddress, returnRaven);
      }

      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: feeRate));
    }
    estimate.setCoinReturn(returnRaven);
    estimate.setExtraFees(pros.settings.network.burnAmounts.reissue);
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2<wu.Transaction, SendEstimate>(tx, estimate);
  }

  Future<Tuple2<wu.Transaction, SendEstimate>> transactionCreateMainAsset(
    SendEstimate estimate,
    int divisibility,
    bool reissuability, {
    required Wallet wallet,
    String? newAssetToAddress,
    String? ownershipToAddress,
    Uint8List? ipfsData,
    wu.FeeRate? feeRate,
  }) async {
    wu.TransactionBuilder? txb;
    wu.Transaction tx;
    int feeSats = 0;
    // Grab required assets for transfer amount
    List<Vout> utxosRaven = <Vout>[];
    final String returnAddress =
        services.wallet.getEmptyAddress(wallet, NodeExposure.internal);
    int returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = wu.TransactionBuilder(
        network: pros.settings.network,
        chainName: pros.settings.chain.name,
      );
      // Grab required RVN for fee + burn
      utxosRaven = await services.balance.collectUTXOs(
          walletId: wallet.id,
          amount: feeSats + pros.settings.network.burnAmounts.issueMain);
      int satsIn = 0;
      for (final Vout utxo in utxosRaven) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.coinValue;
      }
      returnRaven =
          satsIn - pros.settings.network.burnAmounts.issueMain - feeSats;

      txb.generateCreateAssetVouts(
          newAssetToAddress ?? returnAddress,
          ownershipToAddress ?? newAssetToAddress ?? returnAddress,
          estimate.amount,
          estimate.security!.symbol,
          divisibility,
          reissuability,
          ipfsData);

      if (estimate.memo != null) {
        txb.addMemo(estimate.memo, offset: 1);
      }
      if (returnRaven > 0) {
        txb.addChangeToAssetCreationOrReissuance(1, returnAddress, returnRaven);
      }
      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: feeRate));
    }
    estimate.setCoinReturn(returnRaven);
    estimate.setExtraFees(pros.settings.network.burnAmounts.issueMain);
    await txb!.signEachInput(utxosRaven);
    tx = txb.build();
    return Tuple2<wu.Transaction, SendEstimate>(tx, estimate);
  }

  Future<Tuple2<wu.Transaction, SendEstimate>> transactionCreateSubAsset(
    String parentAsset,
    SendEstimate estimate,
    int divisibility,
    bool reissuability, {
    required Wallet wallet,
    String? newAssetToAddress,
    String? parentOwnershipToAddress,
    String? ownershipToAddress,
    Uint8List? ipfsData,
    wu.FeeRate? feeRate,
  }) async {
    wu.TransactionBuilder? txb;
    wu.Transaction tx;
    int feeSats = 0;
    // Grab required assets for transfer amount
    List<Vout> utxosRaven = <Vout>[];
    // 1 virtual ownership asset for the parent
    final List<Vout> utxosSecurity = !<Security?>[
      null,
      pros.securities.currentCoin
    ].contains(estimate.security)
        ? await services.balance.collectUTXOs(
            walletId: wallet.id,
            amount: wu.satsPerCoin,
            security: Security(
              symbol: '$parentAsset!',
              chain: pros.settings.chain,
              net: pros.settings.net,
            ))
        : <Vout>[];
    final String returnAddress =
        services.wallet.getEmptyAddress(wallet, NodeExposure.internal);
    int returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = wu.TransactionBuilder(
        network: pros.settings.network,
        chainName: pros.settings.chain.name,
      );
      // Grab required RVN for fee + burn
      utxosRaven = await services.balance.collectUTXOs(
        walletId: wallet.id,
        amount: feeSats + pros.settings.network.burnAmounts.issueSub,
      );
      int satsIn = 0;
      for (final Vout utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.coinValue;
      }
      returnRaven =
          satsIn - pros.settings.network.burnAmounts.issueSub - feeSats;
      txb.generateCreateSubAssetVouts(
          newAssetToAddress ?? returnAddress,
          ownershipToAddress ?? newAssetToAddress ?? returnAddress,
          parentOwnershipToAddress ?? returnAddress,
          estimate.amount,
          parentAsset,
          estimate.security!.symbol,
          divisibility,
          reissuability,
          ipfsData);
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo, offset: 1);
      }
      if (returnRaven > 0) {
        txb.addChangeToAssetCreationOrReissuance(1, returnAddress, returnRaven);
      }
      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: feeRate));
    }
    estimate.setCoinReturn(returnRaven);
    estimate.setExtraFees(pros.settings.network.burnAmounts.issueSub);
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2<wu.Transaction, SendEstimate>(tx, estimate);
  }

  // Used for unique and message assets
  Future<Tuple2<wu.Transaction, SendEstimate>> transactionCreateChildAsset(
    String parentAsset,
    SendEstimate estimate, {
    required Wallet wallet,
    String? newAssetToAddress,
    String? parentOwnershipToAddress,
    Uint8List? ipfsData,
    wu.FeeRate? feeRate,
  }) async {
    wu.TransactionBuilder? txb;
    wu.Transaction tx;
    int feeSats = 0;
    // Grab required assets for transfer amount
    List<Vout> utxosRaven = <Vout>[];
    // 1 virtual ownership asset for the parent
    final List<Vout> utxosSecurity = !<Security?>[
      null,
      pros.securities.currentCoin
    ].contains(estimate.security)
        ? await services.balance.collectUTXOs(
            walletId: wallet.id,
            amount: wu.satsPerCoin,
            security: Security(
              symbol: '$parentAsset!',
              chain: pros.settings.chain,
              net: pros.settings.net,
            ))
        : <Vout>[];
    final String returnAddress =
        services.wallet.getEmptyAddress(wallet, NodeExposure.internal);
    int returnRaven = -1; // Init to bad val
    final int extraFee = estimate.security!.symbol.contains('~')
        ? pros.settings.network.burnAmounts.issueMessage
        : pros.settings.network.burnAmounts.issueUnique;
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = wu.TransactionBuilder(
        network: pros.settings.network,
        chainName: pros.settings.chain.name,
      );
      // Grab required RVN for fee plus burn
      utxosRaven = await services.balance.collectUTXOs(
        walletId: wallet.id,
        amount: feeSats + extraFee,
      );
      int satsIn = 0;
      for (final Vout utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.coinValue;
      }
      returnRaven = satsIn - extraFee - feeSats;
      txb.generateCreateChildAssetVouts(
          newAssetToAddress ?? returnAddress,
          parentOwnershipToAddress ?? returnAddress,
          parentAsset,
          estimate.security!.symbol,
          ipfsData);
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo, offset: 1);
      }
      if (returnRaven > 0) {
        txb.addChangeToAssetCreationOrReissuance(1, returnAddress, returnRaven);
      }
      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: feeRate));
    }
    estimate.setCoinReturn(returnRaven);
    estimate.setExtraFees(extraFee);
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2<wu.Transaction, SendEstimate>(tx, estimate);
  }

  Future<Tuple2<wu.Transaction, SendEstimate>> transactionBroadcastMessage(
    SendEstimate estimate, {
    required Wallet wallet,
    wu.FeeRate? feeRate,
  }) async {
    if (!(estimate.security!.symbol.contains('!') ||
        estimate.security!.symbol.contains('~'))) {
      // Broadcasts only work with ownership or message channel assets.
      throw ArgumentError.value(estimate.security!.symbol, 'assetName',
          'Can only be an ownership or message channel asset');
    }
    wu.TransactionBuilder? txb;
    wu.Transaction tx;
    int feeSats = 0;
    List<Vout> utxosRaven = <Vout>[];
    final List<Vout> utxosSecurity = await services.balance.collectUTXOs(
        walletId: wallet.id,
        amount: wu.satsPerCoin,
        security: estimate.security);
    final String returnAddress =
        services.wallet.getEmptyAddress(wallet, NodeExposure.internal);
    int returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = wu.TransactionBuilder(
        network: pros.settings.network,
        chainName: pros.settings.chain.name,
      );
      // Grab required RVN for fee plus burn
      utxosRaven = await services.balance.collectUTXOs(
        walletId: wallet.id,
        amount: feeSats,
      );
      int satsIn = 0;
      for (final Vout utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.coinValue;
      }
      returnRaven = satsIn - feeSats;
      if (returnRaven > 0) {
        txb.addOutput(returnAddress, returnRaven);
      }

      if (estimate.memo != null) {
        txb.addMemo(estimate.memo);
      }
      // Sends the asset to the address currently holding it with a message
      txb.addOutput(
        utxosRaven.first.toAddress,
        wu.satsPerCoin,
        asset: estimate.security!.symbol,
        memo: estimate.assetMemo,
      );

      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: feeRate));
    }
    estimate.setCoinReturn(returnRaven);
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2<wu.Transaction, SendEstimate>(tx, estimate);
  }

  Future<Tuple2<wu.Transaction, SendEstimate>> transaction(
    String toAddress,
    SendEstimate estimate, {
    required Wallet wallet,
    wu.FeeRate? feeRate,
    int? assetMemoExpiry,
  }) async {
    wu.TransactionBuilder? txb;
    wu.Transaction tx;
    int feeSats = 0;
    // Grab required assets for transfer amount
    List<Vout> utxosRaven = <Vout>[];
    final List<Vout> utxosSecurity = !<Security?>[
      null,
      pros.securities.currentCoin
    ].contains(estimate.security)
        ? await services.balance.collectUTXOs(
            walletId: wallet.id,
            amount: estimate.amount,
            security: estimate.security,
          )
        : <Vout>[];
    int securityIn = 0;
    for (final Vout utxo in utxosSecurity) {
      securityIn += utxo.assetValue!;
    }
    final int securityChange =
        estimate.security == null ? 0 : securityIn - estimate.amount;
    // must wait for addesses ...?
    final String returnAddress =
        services.wallet.getEmptyAddress(wallet, NodeExposure.internal);
    int returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = wu.TransactionBuilder(
        network: pros.settings.network,
        chainName: pros.settings.chain.name,
      );
      // Grab required RVN for fee (plus amount, maybe)
      utxosRaven = await services.balance.collectUTXOs(
          walletId: wallet.id,
          amount: feeSats + (estimate.security == null ? estimate.amount : 0));
      int satsIn = 0;
      // We also add inputs in this loop
      for (final Vout utxo in utxosRaven) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.coinValue;
      }
      for (final Vout utxo in utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
      }
      returnRaven =
          satsIn - (estimate.security == null ? estimate.amount : 0) - feeSats;
      if (returnRaven > 0) {
        txb.addOutput(returnAddress, returnRaven);
      }
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo);
      }
      txb.addOutput(
        toAddress,
        estimate.amount,
        asset: estimate.security?.symbol,
        memo: estimate.assetMemo,
        expiry: assetMemoExpiry,
      );
      if (securityChange > 0) {
        txb.addOutput(
          returnAddress,
          securityChange,
          asset: estimate.security!.symbol,
        );
      }
      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: feeRate));
    }
    estimate.setCoinReturn(returnRaven);
    estimate.setUTXOs(utxosRaven + utxosSecurity);
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2<wu.Transaction, SendEstimate>(tx, estimate);
  }

  /// we can skip the while loop because we know we want to include all unspents
  /// asside from taking a shortcut, this function is actually necessary because
  /// the other transaction function assume the amount is constant and adds fees
  /// onto it but when sending all you want the fee taken out of the send amount
  Future<Tuple2<wu.Transaction, SendEstimate>> transactionSendAllRVN(
    String toAddress,
    SendEstimate estimate, {
    required Wallet wallet,
    wu.FeeRate? feeRate,
    Set<int>? previousFees,
    int? assetMemoExpiry,
  }) async {
    wu.TransactionBuilder makeTxBuilder(
      List<Vout> utxos,
      SendEstimate estimate,
    ) {
      int total = 0;
      final wu.TransactionBuilder txb = wu.TransactionBuilder(
        network: pros.settings.network,
        chainName: pros.settings.chain.name,
      );
      for (final Vout utxo in utxos) {
        txb.addInput(utxo.transactionId, utxo.position);
        total = total + utxo.coinValue;
      }
      if (total != estimate.amount &&
          total != estimate.amount + estimate.fees) {
        throw Exception(
            'During creation of the "send all" transaction the total amount we '
            'could send changed. Transaction Failed.');
      }
      txb.addOutput(
        toAddress,
        estimate.amount,
        asset: estimate.security?.symbol,
        memo: estimate.assetMemo,
        expiry: assetMemoExpiry,
      );
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo);
      }
      return txb;
    }

    final List<Vout> utxos = await services.balance.collectUTXOs(
      walletId: wallet.id,
      amount: estimate.amount,
    );
    wu.TransactionBuilder txb = makeTxBuilder(utxos, estimate);
    wu.Transaction tx = txb.buildSpoofedSigs();
    estimate.setFees(tx.fee(goal: feeRate));
    estimate.setAmount(estimate.amount - estimate.fees);
    txb = makeTxBuilder(utxos, estimate);
    estimate.setUTXOs(utxos);
    await txb.signEachInput(utxos);
    tx = txb.build();
    return Tuple2<wu.Transaction, SendEstimate>(tx, estimate);
  }

  /// we can skip the while loop because we know we want to include all unspents
  /// asside from taking a shortcut, this function is actually necessary because
  /// the other transaction function assume the amount is constant and adds fees
  /// onto it but when sending all you want the fee taken out of the send amount
  Future<Tuple2<wu.Transaction, SendEstimate>> transactionSweepAll(
    String toAddress,
    SendEstimate estimate, {
    required Wallet wallet,
    required Set<Security> securities,
    wu.FeeRate? feeRate,
    Set<int>? previousFees,
    int? assetMemoExpiry,
  }) async {
    wu.TransactionBuilder makeTxBuilder(
      List<Vout> utxosCurrency,
      Map<Security, List<Vout>> utxosBySecurity,
      SendEstimate estimate,
    ) {
      final wu.TransactionBuilder txb = wu.TransactionBuilder(
        network: pros.settings.network,
        chainName: pros.settings.chain.name,
      );
      for (final Vout utxo in utxosCurrency) {
        txb.addInput(utxo.transactionId, utxo.position);
      }
      txb.addOutput(toAddress, estimate.amount);
      for (final Vout utxo
          in utxosBySecurity.values.expand((List<Vout> e) => e)) {
        txb.addInput(utxo.transactionId, utxo.position);
      }
      for (final MapEntry<Security, List<Vout>> entry
          in utxosBySecurity.entries) {
        final int amount = entry.value
            .fold(0, (int? agg, Vout v) => v.assetValue! + (agg ?? 0));
        txb.addOutput(toAddress, amount, asset: entry.key.symbol);
      }
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo);
      }
      return txb;
    }

    final List<Vout> utxosCurrency = await services.balance.collectUTXOs(
      walletId: wallet.id,
      amount: estimate.amount,
    );
    final Map<Security, List<Vout>> utxosBySecurity = <Security, List<Vout>>{};
    for (final Security security
        in securities.where((Security e) => e != pros.securities.currentCoin)) {
      utxosBySecurity[security] = await services.balance.collectUTXOs(
        walletId: wallet.id,
        amount: pros.balances.primaryIndex.getOne(wallet.id, security)!.value,
        security: security,
      );
    }
    wu.TransactionBuilder txb =
        makeTxBuilder(utxosCurrency, utxosBySecurity, estimate);
    wu.Transaction tx = txb.buildSpoofedSigs();
    estimate.setFees(tx.fee(goal: feeRate));
    estimate.setAmount(estimate.amount - estimate.fees);
    txb = makeTxBuilder(utxosCurrency, utxosBySecurity, estimate);
    final List<Vout> spentUtxos = utxosCurrency +
        utxosBySecurity.values.expand((List<Vout> e) => e).toList();
    estimate.setUTXOs(spentUtxos);
    await txb.signEachInput(spentUtxos);
    // gives error: incomplete transaction even though inputs and outputs are there and signed, I think.
    tx = txb.build();
    return Tuple2<wu.Transaction, SendEstimate>(tx, estimate);
  }

  /// transactionSweepAll above is only called when it is known there are no
  /// more than 1000 inputs. This function is called when there are more than
  /// 1000 asset inputs.
  Future<Tuple2<wu.Transaction, SendEstimate>>
      transactionSweepAssetIncrementally(
    String toAddress,
    SendEstimate estimate, {
    required Wallet wallet,
    required Map<Security, List<Vout>> utxosBySecurity,
    wu.FeeRate? feeRate,
    int? assetMemoExpiry,
  }) async {
    wu.TransactionBuilder? txb;
    wu.Transaction tx;
    int feeSats = 0;
    // Grab required assets for transfer amount
    List<Vout> utxosRaven = <Vout>[];
    final List<Vout> utxosSecurity =
        utxosBySecurity.values.expand((List<Vout> e) => e).toList();
    // must wait for addesses ...?
    final String returnAddress =
        services.wallet.getEmptyAddress(wallet, NodeExposure.internal);
    int returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = wu.TransactionBuilder(
        network: pros.settings.network,
        chainName: pros.settings.chain.name,
      );
      // Grab required RVN for fee (plus amount, maybe)
      utxosRaven = await services.balance
          .collectUTXOs(walletId: wallet.id, amount: feeSats);
      int satsIn = 0;
      // We also add inputs in this loop
      for (final Vout utxo in utxosRaven) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.coinValue;
      }
      for (final Vout utxo in utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
      }
      returnRaven = satsIn - feeSats;
      if (returnRaven > 0) {
        txb.addOutput(returnAddress, returnRaven);
      }
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo);
      }
      for (final MapEntry<Security, List<Vout>> entry
          in utxosBySecurity.entries) {
        txb.addOutput(
            toAddress,
            entry.value
                .fold(0, (int? agg, Vout v) => v.assetValue! + (agg ?? 0)),
            asset: entry.key.symbol,
            memo: estimate.assetMemo,
            expiry: assetMemoExpiry);
      }
      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: feeRate));
    }
    estimate.setCoinReturn(returnRaven);
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    estimate.setUTXOs(utxosRaven + utxosSecurity);
    return Tuple2<wu.Transaction, SendEstimate>(tx, estimate);
  }

  Future<Tuple2<wu.Transaction, SendEstimate>>
      transactionSendAllRVNIncrementally(
    String toAddress,
    SendEstimate estimate, {
    required Wallet wallet,
    required List<Vout> utxosCurrency,
    wu.FeeRate? feeRate,
    int? assetMemoExpiry,
  }) async {
    wu.TransactionBuilder makeTxBuilder(
      List<Vout> utxos,
      SendEstimate estimate,
    ) {
      final wu.TransactionBuilder txb = wu.TransactionBuilder(
        network: pros.settings.network,
        chainName: pros.settings.chain.name,
      );
      for (final Vout utxo in utxos) {
        txb.addInput(utxo.transactionId, utxo.position);
      }
      txb.addOutput(
        toAddress,
        estimate.amount,
        asset: estimate.security?.symbol,
        memo: estimate.assetMemo,
        expiry: assetMemoExpiry,
      );
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo);
      }
      return txb;
    }

    wu.TransactionBuilder txb = makeTxBuilder(utxosCurrency, estimate);
    wu.Transaction tx = txb.buildSpoofedSigs();
    estimate.setFees(tx.fee(goal: feeRate));
    estimate.setAmount(estimate.amount - estimate.fees);
    estimate.setUTXOs(utxosCurrency);
    txb = makeTxBuilder(utxosCurrency, estimate);
    await txb.signEachInput(utxosCurrency);
    tx = txb.build();
    return Tuple2<wu.Transaction, SendEstimate>(tx, estimate);
  }

  /// CLAIM FEATURE:
  /// instead of getting the vouts as we normally would, we get them from stream
  Future<Tuple2<wu.Transaction, SendEstimate>> claimAllEVR(
    String toAddress,
    SendEstimate estimate, {
    required Wallet wallet,
    wu.FeeRate? feeRate,
    Set<int>? previousFees,
    int? assetMemoExpiry,
  }) async {
    wu.TransactionBuilder makeTxBuilder(
      List<Vout> utxos,
      SendEstimate estimate,
    ) {
      final wu.TransactionBuilder txb = wu.TransactionBuilder(
        network: pros.settings.network,
        chainName: pros.settings.chain.name,
      );
      for (final Vout utxo in utxos) {
        txb.addInput(utxo.transactionId, utxo.position);
      }
      txb.addOutput(
        toAddress,
        estimate.amount,
        asset: estimate.security?.symbol,
        memo: estimate.assetMemo,
        expiry: assetMemoExpiry,
      );
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo);
      }
      return txb;
    }

    final List<Vout> utxos = estimate.utxos;
    wu.TransactionBuilder txb = makeTxBuilder(utxos, estimate);
    wu.Transaction tx = txb.buildSpoofedSigs();
    estimate.setFees(tx.fee(goal: feeRate));
    estimate.setAmount(estimate.amount - estimate.fees);
    txb = makeTxBuilder(utxos, estimate);
    await txb.signEachInput(utxos);
    tx = txb.build();
    return Tuple2<wu.Transaction, SendEstimate>(tx, estimate);
  }
}
