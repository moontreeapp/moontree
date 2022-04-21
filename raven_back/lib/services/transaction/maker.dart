import 'dart:typed_data';

import 'package:raven_back/raven_back.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' as ravencoin;
import 'package:ravencoin_wallet/src/fee.dart';
import 'package:tuple/tuple.dart';

import 'sign.dart';

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
  late String?
      parent; // you have to use the wallet that holds the prent if sub asset

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

  @override
  List<Object?> get props => [
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
  List<String> get propNames => [
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

  Security get security =>
      Security(symbol: fullName, securityType: SecurityType.RavenAsset);
}

class GenericReissueRequest with ToStringMixin {
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
  late String?
      parent; // you have to use the wallet that holds the prent if sub asset

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

  @override
  List<Object?> get props => [
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
  List<String> get propNames => [
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

  Security get security =>
      Security(symbol: fullName, securityType: SecurityType.RavenAsset);
}

class SendRequest with ToStringMixin {
  late bool sendAll;
  late String sendAddress;
  late double holding;
  late String visibleAmount;
  late int sendAmountAsSats;
  late TxGoal feeGoal;
  late Wallet wallet;
  late Security? security;
  late String? assetMemo;
  late String? memo;
  late String? note;

  SendRequest({
    required this.sendAll,
    required this.sendAddress,
    required this.holding,
    required this.visibleAmount,
    required this.sendAmountAsSats,
    required this.feeGoal,
    required this.wallet,
    this.security,
    this.assetMemo,
    this.memo,
    this.note,
  });

  @override
  List<Object> get props => [
        sendAll,
        sendAddress,
        holding,
        visibleAmount,
        sendAmountAsSats,
        feeGoal,
        wallet,
        security ?? '?',
        assetMemo ?? '?',
        memo ?? '?',
        note ?? '?',
      ];
  @override
  List<String> get propNames => [
        'sendAll',
        'sendAddress',
        'holding',
        'visibleAmount',
        'sendAmountAsSats',
        'feeGoal',
        'wallet',
        'security',
        'assetMemo',
        'memo',
        'note',
      ];
}

class SendEstimate with ToStringMixin {
  int amount; //sats
  int fees;
  List<Vout> utxos;
  Security? security;
  Uint8List? assetMemo;
  String? memo;
  int extraFees = 0;
  bool creation;

  SendEstimate(
    this.amount, {
    this.fees = 0,
    List<Vout>? utxos,
    this.security,
    this.assetMemo,
    this.memo,
    this.creation = false,
  }) : utxos = utxos ?? [];

  @override
  List<Object?> get props => [
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
  List<String> get propNames => [
        'amount',
        'fees',
        'utxos',
        'security',
        'assetMemo',
        'memo',
        'extraFees',
        'creation',
      ];

  int get total => (creation ? 0 : amount) + fees + extraFees;
  int get utxoTotal => utxos.fold(
      0, (int total, vout) => total + vout.securityValue(security: security));

  int get changeDue => utxoTotal - total;

  factory SendEstimate.copy(SendEstimate detail) {
    return SendEstimate(detail.amount,
        fees: detail.fees, utxos: detail.utxos.toList());
  }

  void setFees(int fees_) => fees = fees_;
  void setExtraFees(int fees_) => extraFees = fees_;
  void setCreation(bool creation_) => creation = creation_;
  void setUTXOs(List<Vout> utxos_) => utxos = utxos_;
  void setAmount(int amount_) => amount = amount_;
}

class TransactionMaker {
  Future<Tuple2<ravencoin.Transaction, SendEstimate>> transactionBy(
    SendRequest sendRequest,
  ) async {
    var tuple;
    var estimate = SendEstimate(
      sendRequest.sendAmountAsSats,
      security: sendRequest.security,
      assetMemo: sendRequest.assetMemo?.base58Decode,
      memo: sendRequest.memo,
    );

    tuple = (sendRequest.sendAll ||
                double.parse(sendRequest.visibleAmount) ==
                    sendRequest.holding) &&
            (sendRequest.security == null ||
                sendRequest.security == res.securities.RVN)
        ? await transactionSendAllRVN(
            sendRequest.sendAddress,
            estimate,
            wallet: sendRequest.wallet,
            goal: sendRequest.feeGoal,
          )
        : await transaction(
            sendRequest.sendAddress,
            estimate,
            wallet: sendRequest.wallet,
            goal: sendRequest.feeGoal,
          );
    return tuple;
  }

  Future<Tuple2<ravencoin.Transaction, SendEstimate>> createTransactionBy(
    GenericCreateRequest createRequest,
  ) async {
    var estimate = SendEstimate(
      ((createRequest.quantity ?? 1) * 100000000).toInt(),
      security: createRequest.security,
      creation: true,
      //assetMemo: createRequest.assetMemo, // not on front end
      //memo: createRequest.memo, // op return memos allowed, but not on front end
    );
    print(estimate.total);
    // MOONTREETESTASSET
    // QmQsUFxsd4S5FZGxQJjVSBVSPv8Gt1adRE16nACt2zv6KP

    print('createTransactionBy $estimate');
    return createRequest.isNFT || createRequest.isChannel
        ? await transactionCreateChildAsset(
            createRequest.parent!,
            estimate,
            wallet: createRequest.wallet,
            ipfsData: createRequest.assetData,
            goal: TxGoals.standard,
          )
        : createRequest.isSub
            ? await transactionCreateSubAsset(
                createRequest.parent!,
                estimate,
                createRequest.decimals ?? 0,
                createRequest.reissuable ?? false,
                wallet: createRequest.wallet,
                ipfsData: createRequest.assetData,
                goal: TxGoals.standard,
              )
            :
            // Restricted and Qualifier
            await transactionCreateMainAsset(
                estimate,
                createRequest.decimals ?? 0,
                createRequest.reissuable ?? false,
                wallet: createRequest.wallet,
                ipfsData: createRequest.assetData,
                goal: TxGoals.standard,
              );
  }

  Future<Tuple2<ravencoin.Transaction, SendEstimate>> reissueTransactionBy(
    GenericReissueRequest reissueRequest,
  ) async {
    var estimate = SendEstimate(
      ((reissueRequest.quantity ?? 0) * 100000000).toInt(),
      security: reissueRequest.security,
      creation: true,
    );
    print('reissueTransactionBy $estimate');
    return reissueRequest.isRestricted
        ? await transactionReissueRestrictedAsset(
            estimate,
            reissueRequest.originalDecimals ?? 0,
            (reissueRequest.originalQuantity! * 100000000).toInt(),
            reissueRequest.decimals ?? 0,
            reissueRequest.reissuable ?? false,
            wallet: reissueRequest.wallet,
            verifier: null,
            newAssetToAddress: null,
            ownershipToAddress: null,
            ipfsData:
                reissueRequest.assetData == reissueRequest.originalAssetData
                    ? null
                    : reissueRequest.assetData,
            goal: TxGoals.standard)
        : await transactionReissueAsset(
            estimate,
            reissueRequest.originalDecimals ?? 0,
            (reissueRequest.originalQuantity! * 100000000).toInt(),
            reissueRequest.decimals ?? 0,
            reissueRequest.reissuable ?? false,
            wallet: reissueRequest.wallet,
            newAssetToAddress: null,
            ownershipToAddress: null,
            ipfsData:
                reissueRequest.assetData == reissueRequest.originalAssetData
                    ? null
                    : reissueRequest.assetData,
            goal: TxGoals.standard);
  }

  Future<Tuple2<ravencoin.Transaction, SendEstimate>>
      transactionCreateQualifier(
    SendEstimate estimate, {
    required Wallet wallet,
    Uint8List? ipfsData,
    TxGoal? goal,
    String? newAssetToAddress,
  }) async {
    ravencoin.TransactionBuilder? txb;
    ravencoin.Transaction tx;

    if (estimate.amount > 10 * 100000000) {
      throw ArgumentError('Amount must be at most 10');
    }
    if (estimate.security == null || estimate.security!.symbol[0] != '#') {
      throw ArgumentError('Asset must be a qualifying asset');
    }

    var feeSats = 0;
    var utxosRaven = <Vout>[];
    var returnAddress = services.wallet.getChangeAddress(wallet);
    var returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN for fee + burn
      utxosRaven = await services.balance.collectUTXOs(
          amount: feeSats + res.settings.network.burnAmounts.issueQualifier,
          security: null);
      var satsIn = 0;
      for (var utxo in utxosRaven) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.rvnValue;
      }
      returnRaven =
          satsIn - res.settings.network.burnAmounts.issueQualifier - feeSats;

      txb.generateCreateQualifierVouts(newAssetToAddress ?? returnAddress,
          estimate.amount, estimate.security!.symbol, ipfsData);

      if (estimate.memo != null) {
        txb.addMemo(estimate.memo, offset: 1);
      }
      if (returnRaven > 0) {
        txb.addChangeToAssetCreationOrReissuance(1, returnAddress, returnRaven);
      }
      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: goal));
    }
    estimate.setExtraFees(res.settings.network.burnAmounts.issueQualifier);
    await txb!.signEachInput(utxosRaven);
    tx = txb.build();
    return Tuple2(tx, estimate);
  }

  Future<Tuple2<ravencoin.Transaction, SendEstimate>>
      transactionCreateSubQualifier(
    SendEstimate estimate,
    String parentAsset, {
    required Wallet wallet,
    Uint8List? ipfsData,
    TxGoal? goal,
    String? newAssetToAddress,
    String? parentAssetToAddress,
  }) async {
    ravencoin.TransactionBuilder? txb;
    ravencoin.Transaction tx;

    if (estimate.amount > 10 * 100000000) {
      throw ArgumentError('Amount must be at most 10');
    }
    if (estimate.security == null || estimate.security!.symbol[0] != '#') {
      throw ArgumentError('Asset must be a qualifying asset');
    }
    var feeSats = 0;
    // Grab required assets for transfer amount
    var utxosRaven = <Vout>[];
    // 1 parent qualifier asset, may have leftover
    var utxosSecurity = estimate.security != null
        ? await services.balance.collectUTXOs(
            amount: 100000000,
            security: Security(
                symbol: parentAsset, securityType: SecurityType.RavenAsset))
        : <Vout>[];
    var securityIn = 0;
    for (var utxo in utxosSecurity) {
      securityIn += utxo.assetValue!;
    }
    var securityChange = securityIn - 100000000;

    var returnAddress = services.wallet.getChangeAddress(wallet);
    var returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN for fee + burn
      utxosRaven = await services.balance.collectUTXOs(
        amount: feeSats + res.settings.network.burnAmounts.issueSubQualifier,
        security: null,
      );
      var satsIn = 0;
      for (var utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.rvnValue;
      }
      returnRaven =
          satsIn - res.settings.network.burnAmounts.issueSubQualifier - feeSats;
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
      estimate.setFees(tx.fee(goal: goal));
    }
    estimate.setExtraFees(res.settings.network.burnAmounts.issueSubQualifier);
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2(tx, estimate);
  }

  Future<Tuple2<ravencoin.Transaction, SendEstimate>>
      transactionCreateRestricted(
    SendEstimate estimate,
    int divisibility,
    bool reissuable, {
    required Wallet wallet,
    String? newAssetToAddress,
    String? parentAssetToAddress,
    Uint8List? ipfsData,
    String? verifier,
    TxGoal? goal,
  }) async {
    ravencoin.TransactionBuilder? txb;
    ravencoin.Transaction tx;
    if (estimate.security == null || estimate.security!.symbol[0] != '\$') {
      throw ArgumentError('Asset must be a restricted asset');
    }
    var feeSats = 0;
    // Grab required assets for transfer amount
    var utxosRaven = <Vout>[];
    // 1 virtual ownership asset for the parent
    var utxosSecurity = estimate.security != null
        ? await services.balance.collectUTXOs(
            amount: 100000000,
            security: Security(
                symbol: estimate.security!.symbol.substring(1) + '!',
                securityType: SecurityType.RavenAsset))
        : <Vout>[];
    var returnAddress = services.wallet.getChangeAddress(wallet);
    var returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN for fee + burn
      utxosRaven = await services.balance.collectUTXOs(
        amount: feeSats + res.settings.network.burnAmounts.issueRestricted,
        security: null,
      );
      var satsIn = 0;
      for (var utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.rvnValue;
      }
      returnRaven =
          satsIn - res.settings.network.burnAmounts.issueRestricted - feeSats;

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
      estimate.setFees(tx.fee(goal: goal));
    }
    estimate.setExtraFees(res.settings.network.burnAmounts.issueRestricted);
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2(tx, estimate);
  }

  Future<Tuple2<ravencoin.Transaction, SendEstimate>>
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
    TxGoal? goal,
  }) async {
    ravencoin.TransactionBuilder? txb;
    ravencoin.Transaction tx;

    if (estimate.security == null || estimate.security!.symbol[0] != '\$') {
      throw ArgumentError('Asset must be a restricted asset');
    }

    var feeSats = 0;
    // Grab required assets for transfer amount
    var utxosRaven = <Vout>[];
    var utxosSecurity = await services.balance.collectUTXOs(
        amount: 100000000, // 1 virtual sat for ownership asset
        security: Security(
            symbol: estimate.security!.symbol.substring(1) + '!',
            securityType: SecurityType.RavenAsset));
    var returnAddress = services.wallet.getChangeAddress(wallet);
    var returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN for fee + burn amount
      utxosRaven = await services.balance.collectUTXOs(
        amount: feeSats + res.settings.network.burnAmounts.reissue,
        security: null,
      );
      var satsIn = 0;
      for (var utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.rvnValue;
      }
      returnRaven = satsIn - res.settings.network.burnAmounts.reissue - feeSats;

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
      estimate.setFees(tx.fee(goal: goal));
    }
    estimate.setExtraFees(res.settings.network.burnAmounts.reissue);
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2(tx, estimate);
  }

  Future<Tuple2<ravencoin.Transaction, SendEstimate>> transactionQualifyAddress(
    SendEstimate estimate,
    String qualifyingAsset,
    String addressToQualify,
    bool tag, {
    required Wallet wallet,
    String? qualifierToAddress,
    TxGoal? goal,
  }) async {
    ravencoin.TransactionBuilder? txb;
    ravencoin.Transaction tx;
    if (estimate.security == null ||
        estimate.security!.symbol.contains(RegExp(r'^[\$#].*$'))) {
      throw ArgumentError('Asset must be a qualifier or a restricted asset');
    }
    var feeSats = 0;
    // Grab required assets for transfer amount
    var utxosRaven = <Vout>[];
    var utxosSecurity = await services.balance.collectUTXOs(
        amount: 100000000, // 1 sat for ownership asset
        security: Security(
            symbol: estimate.security!.symbol[0] == '\$'
                ? estimate.security!.symbol.substring(1) + '!'
                : estimate.security!.symbol,
            securityType: SecurityType.RavenAsset));
    var securityIn = 0; // May be qualifier
    for (var utxo in utxosSecurity) {
      securityIn += utxo.assetValue!;
    }
    var securityChange = securityIn - 100000000;

    var returnAddress = services.wallet.getChangeAddress(wallet);
    var returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN for fee + burn amount
      utxosRaven = await services.balance.collectUTXOs(
        amount: feeSats + res.settings.network.burnAmounts.addTag,
        security: null,
      );
      var satsIn = 0;
      for (var utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.rvnValue;
      }
      returnRaven = satsIn - res.settings.network.burnAmounts.addTag - feeSats;

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
            asset: estimate.security!.symbol[0] == '\$'
                ? estimate.security!.symbol.substring(1) + '!'
                : estimate.security!.symbol);
      }

      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: goal));
    }
    estimate.setExtraFees(res.settings.network.burnAmounts.addTag);
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2(tx, estimate);
  }

  Future<Tuple2<ravencoin.Transaction, SendEstimate>> transactionReissueAsset(
    SendEstimate estimate,
    int originalDivisibility,
    int currentSatsInCirculation,
    int newDivisibility,
    bool reissuability, {
    required Wallet wallet,
    String? newAssetToAddress,
    String? ownershipToAddress,
    Uint8List? ipfsData,
    TxGoal? goal,
  }) async {
    ravencoin.TransactionBuilder? txb;
    ravencoin.Transaction tx;
    var feeSats = 0;
    // Grab required assets for transfer amount
    var utxosRaven = <Vout>[];
    var utxosSecurity = await services.balance.collectUTXOs(
        amount: 100000000, // 1 virtual sat for ownership asset
        security: Security(
            symbol: estimate.security!.symbol + '!',
            securityType: SecurityType.RavenAsset));
    var returnAddress = services.wallet.getChangeAddress(wallet);
    var returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN for fee + burn amount
      utxosRaven = await services.balance.collectUTXOs(
        amount: feeSats + res.settings.network.burnAmounts.reissue,
        security: null,
      );
      var satsIn = 0;
      for (var utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.rvnValue;
      }
      returnRaven = satsIn - res.settings.network.burnAmounts.reissue - feeSats;

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
      estimate.setFees(tx.fee(goal: goal));
    }
    estimate.setExtraFees(res.settings.network.burnAmounts.reissue);
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2(tx, estimate);
  }

  Future<Tuple2<ravencoin.Transaction, SendEstimate>>
      transactionCreateMainAsset(
    SendEstimate estimate,
    int divisibility,
    bool reissuability, {
    required Wallet wallet,
    String? newAssetToAddress,
    String? ownershipToAddress,
    Uint8List? ipfsData,
    TxGoal? goal,
  }) async {
    ravencoin.TransactionBuilder? txb;
    ravencoin.Transaction tx;
    var feeSats = 0;
    // Grab required assets for transfer amount
    var utxosRaven = <Vout>[];
    var returnAddress = services.wallet.getChangeAddress(wallet);
    var returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN for fee + burn
      utxosRaven = await services.balance.collectUTXOs(
          amount: feeSats + res.settings.network.burnAmounts.issueMain,
          security: null);
      var satsIn = 0;
      for (var utxo in utxosRaven) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.rvnValue;
      }
      returnRaven =
          satsIn - res.settings.network.burnAmounts.issueMain - feeSats;

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
      estimate.setFees(tx.fee(goal: goal));
    }
    estimate.setExtraFees(res.settings.network.burnAmounts.issueMain);
    await txb!.signEachInput(utxosRaven);
    tx = txb.build();
    return Tuple2(tx, estimate);
  }

  Future<Tuple2<ravencoin.Transaction, SendEstimate>> transactionCreateSubAsset(
    String parentAsset,
    SendEstimate estimate,
    int divisibility,
    bool reissuability, {
    required Wallet wallet,
    String? newAssetToAddress,
    String? parentOwnershipToAddress,
    String? ownershipToAddress,
    Uint8List? ipfsData,
    TxGoal? goal,
  }) async {
    ravencoin.TransactionBuilder? txb;
    ravencoin.Transaction tx;
    var feeSats = 0;
    // Grab required assets for transfer amount
    var utxosRaven = <Vout>[];
    // 1 virtual ownership asset for the parent
    var utxosSecurity = estimate.security != null
        ? await services.balance.collectUTXOs(
            amount: 100000000,
            security: Security(
                symbol: parentAsset + '!',
                securityType: SecurityType.RavenAsset))
        : <Vout>[];
    var returnAddress = services.wallet.getChangeAddress(wallet);
    var returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN for fee + burn
      utxosRaven = await services.balance.collectUTXOs(
        amount: feeSats + res.settings.network.burnAmounts.issueSub,
        security: null,
      );
      var satsIn = 0;
      for (var utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.rvnValue;
      }
      returnRaven =
          satsIn - res.settings.network.burnAmounts.issueSub - feeSats;
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
      estimate.setFees(tx.fee(goal: goal));
    }
    estimate.setExtraFees(res.settings.network.burnAmounts.issueSub);
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2(tx, estimate);
  }

  // Used for unique and message assets
  Future<Tuple2<ravencoin.Transaction, SendEstimate>>
      transactionCreateChildAsset(
    String parentAsset,
    SendEstimate estimate, {
    required Wallet wallet,
    String? newAssetToAddress,
    String? parentOwnershipToAddress,
    Uint8List? ipfsData,
    TxGoal? goal,
  }) async {
    ravencoin.TransactionBuilder? txb;
    ravencoin.Transaction tx;
    var feeSats = 0;
    // Grab required assets for transfer amount
    var utxosRaven = <Vout>[];
    // 1 virtual ownership asset for the parent
    var utxosSecurity = estimate.security != null
        ? await services.balance.collectUTXOs(
            amount: 100000000,
            security: Security(
                symbol: parentAsset + '!',
                securityType: SecurityType.RavenAsset))
        : <Vout>[];
    var returnAddress = services.wallet.getChangeAddress(wallet);
    var returnRaven = -1; // Init to bad val
    var extraFee = (estimate.security!.symbol.contains('~')
        ? res.settings.network.burnAmounts.issueMessage
        : res.settings.network.burnAmounts.issueUnique);
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN for fee plus burn
      utxosRaven = await services.balance.collectUTXOs(
        amount: feeSats + extraFee,
        security: null,
      );
      var satsIn = 0;
      for (var utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.rvnValue;
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
      estimate.setFees(tx.fee(goal: goal));
    }
    estimate.setExtraFees(extraFee);
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2(tx, estimate);
  }

  Future<Tuple2<ravencoin.Transaction, SendEstimate>>
      transactionBroadcastMessage(
    SendEstimate estimate, {
    required Wallet wallet,
    TxGoal? goal,
  }) async {
    if (!(estimate.security!.symbol.contains('!') ||
        estimate.security!.symbol.contains('~'))) {
      // Broadcasts only work with ownership or message channel assets.
      throw ArgumentError.value(estimate.security!.symbol, 'assetName',
          'Can only be an ownership or message channel asset');
    }
    ravencoin.TransactionBuilder? txb;
    ravencoin.Transaction tx;
    var feeSats = 0;
    var utxosRaven = <Vout>[];
    var utxosSecurity = await services.balance
        .collectUTXOs(amount: 100000000, security: estimate.security!);
    var returnAddress = services.wallet.getChangeAddress(wallet);
    var returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN for fee plus burn
      utxosRaven = await services.balance.collectUTXOs(
        amount: feeSats,
        security: null,
      );
      var satsIn = 0;
      for (var utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.rvnValue;
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
        100000000,
        asset: estimate.security!.symbol,
        memo: estimate.assetMemo!,
      );

      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: goal));
    }
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2(tx, estimate);
  }

  Future<Tuple2<ravencoin.Transaction, SendEstimate>> transaction(
    String toAddress,
    SendEstimate estimate, {
    required Wallet wallet,
    TxGoal? goal,
    int? assetMemoExpiry,
  }) async {
    ravencoin.TransactionBuilder? txb;
    ravencoin.Transaction tx;
    var feeSats = 0;
    // Grab required assets for transfer amount
    var utxosRaven = <Vout>[];
    var utxosSecurity = estimate.security != null
        ? await services.balance.collectUTXOs(
            amount: estimate.amount,
            security: estimate.security,
          )
        : <Vout>[];
    var securityIn = 0;
    for (var utxo in utxosSecurity) {
      securityIn += utxo.assetValue!;
    }
    var securityChange =
        estimate.security == null ? 0 : securityIn - estimate.amount;
    var returnAddress = services.wallet.getChangeAddress(wallet);
    var returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN for fee (plus amount, maybe)
      utxosRaven = await services.balance.collectUTXOs(
          amount: feeSats + (estimate.security == null ? estimate.amount : 0),
          security: null);
      var satsIn = 0;
      // We also add inputs in this loop
      for (var utxo in utxosRaven) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.rvnValue;
      }
      for (var utxo in utxosSecurity) {
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
      estimate.setFees(tx.fee(goal: goal));
    }
    await txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2(tx, estimate);
  }

  // we can skip the while loop because we know we want to include all unspents
  Future<Tuple2<ravencoin.Transaction, SendEstimate>> transactionSendAllRVN(
    String toAddress,
    SendEstimate estimate, {
    required Wallet wallet,
    TxGoal? goal,
    Set<int>? previousFees,
  }) async {
    ravencoin.TransactionBuilder makeTxBuilder(
        List<Vout> utxos, SendEstimate estimate) {
      var total = 0;
      var txb = ravencoin.TransactionBuilder(network: res.settings.network);
      for (var utxo in utxos) {
        txb.addInput(utxo.transactionId, utxo.position);
        total = total + utxo.rvnValue;
      }
      txb.addOutput(toAddress, estimate.amount);
      return txb;
    }

    var utxos = await services.balance.collectUTXOs(
      amount: estimate.amount,
      security: null,
    );
    var txb = makeTxBuilder(utxos, estimate);
    var tx = txb.buildSpoofedSigs();
    estimate.setFees(tx.fee(goal: goal));
    estimate.setAmount(estimate.amount - estimate.fees);
    txb = makeTxBuilder(utxos, estimate);
    await txb.signEachInput(utxos);
    tx = txb.build();
    return Tuple2(tx, estimate);
  }
}
