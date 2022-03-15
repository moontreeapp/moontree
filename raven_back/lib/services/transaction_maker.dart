import 'package:raven_back/raven_back.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' as ravencoin;
import 'package:ravencoin_wallet/src/fee.dart';
import 'package:tuple/tuple.dart';

import 'transaction/sign.dart';

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

class GenericCreateRequest {
  late String name;
  late String ipfs;
  late int? quantity;
  late int? decimals;
  late String? verifier;
  late bool? reissuable;
  late String?
      parent; // you have to use the wallet that holds the prent if sub asset

  GenericCreateRequest({
    required this.name,
    required this.ipfs,
    this.quantity,
    this.decimals,
    this.verifier,
    this.reissuable,
    this.parent,
  });
}

class SendRequest {
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
  });
}

class SendEstimate {
  int amount;
  int fees;
  List<Vout> utxos;
  Security? security;
  String? assetMemo;
  String? memo;

  SendEstimate(
    this.amount, {
    this.fees = 0,
    List<Vout>? utxos,
    this.security,
    this.assetMemo,
    this.memo,
  }) : utxos = utxos ?? [];

  @override
  String toString() => 'amount: $amount, fees: $fees, utxos: $utxos';

  int get total => amount + fees;
  int get utxoTotal => utxos.fold(
      0, (int total, vout) => total + vout.securityValue(security: security));

  int get changeDue => utxoTotal - total;

  factory SendEstimate.copy(SendEstimate detail) {
    return SendEstimate(detail.amount,
        fees: detail.fees, utxos: detail.utxos.toList());
  }

  void setFees(int fees_) => fees = fees_;
  void setUTXOs(List<Vout> utxos_) => utxos = utxos_;
  void setAmount(int amount_) => amount = amount_;
}

class TransactionMaker {
  Tuple2<ravencoin.Transaction, SendEstimate> transactionBy(
    SendRequest sendRequest,
  ) {
    var tuple;
    var estimate = SendEstimate(
      sendRequest.sendAmountAsSats,
      security: sendRequest.security,
      assetMemo: sendRequest.assetMemo,
      memo: sendRequest.memo,
    );

    tuple = (sendRequest.sendAll ||
            double.parse(sendRequest.visibleAmount) == sendRequest.holding)
        ? (sendRequest.security == null
            ? transactionSendAllRVN(
                sendRequest.sendAddress,
                estimate,
                wallet: sendRequest.wallet,
                goal: sendRequest.feeGoal,
              )
            : transactionSendAll(
                sendRequest.sendAddress,
                estimate,
                wallet: sendRequest.wallet,
                goal: sendRequest.feeGoal,
              ))
        : transaction(
            sendRequest.sendAddress,
            estimate,
            wallet: sendRequest.wallet,
            goal: sendRequest.feeGoal,
          );
    return tuple;
  }

  Tuple2<ravencoin.Transaction, SendEstimate> transactionReissueAsset(
    String newAssetToAddress,
    SendEstimate estimate,
    int originalDivisibility,
    int currentSatsInCirculation,
    int newDivisibility,
    bool reissuability, {
    String? ownershipToAddress,
    Uint8List? ipfsData,
    required Wallet wallet,
    TxGoal? goal,
  }) {
    // This is a "coinbase" for assets. Only need RVN vins and ownership vin.
    var ownership_utxo = services.balance.collectUTXOs(
      wallet,
      amount: 100000000,
      security: Security(
          symbol: estimate.security!.symbol + '!',
          securityType: SecurityType.RavenAsset),
    );
    if (ownership_utxo.isEmpty) {
      throw ArgumentError('We don\'t own the ownership asset!');
    }
    var rvn_utxos = <Vout>[];
    var txb;
    var tx;
    var fee_sats = 0;
    var sats_returned = -1; // Init to bad val

    var return_address =
        services.wallet.getChangeWallet(wallet).address; // takes the longest

    var rebuild = true;
    while (sats_returned < 0 || rebuild) {
      rebuild = false; // must rebuild transaction at least once.
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN for fee
      rvn_utxos = services.balance.collectUTXOs(
        wallet,
        amount: (estimate.security == null ? estimate.amount : 0) + fee_sats,
        security: null,
      );

      var sats_in = 0;
      for (var utxo in rvn_utxos + ownership_utxo) {
        txb.addInput(utxo.transactionId, utxo.position);
        // Update avaliable RVN
        sats_in += utxo.rvnValue;
      }

      sats_returned =
          sats_in - res.settings.network.burnAmounts.reissue - fee_sats;

      txb.generateCreateReissueVouts(
          newAssetToAddress,
          ownershipToAddress ?? newAssetToAddress,
          currentSatsInCirculation,
          estimate.amount,
          estimate.security!.symbol,
          originalDivisibility,
          newDivisibility,
          reissuability,
          ipfsData);

      txb.addChangeToAssetCreationOrReissuance(
          2, return_address, sats_returned);
      // Add transaction memo if one is given
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo, offset: 2);
      }

      tx = txb.buildSpoofedSigs();
      fee_sats = tx.fee(goal);
    }
    txb.signEachInput(rvn_utxos + ownership_utxo);
    tx = txb.build();
    estimate.setFees(fee_sats);
    return Tuple2(tx, estimate);
  }

  Tuple2<ravencoin.Transaction, SendEstimate> transactionCreateMainAsset(
    String newAssetToAddress,
    SendEstimate estimate,
    int divisibility,
    bool reissuability, {
    String? ownershipToAddress,
    Uint8List? ipfsData,
    required Wallet wallet,
    TxGoal? goal,
  }) {
    // This is a "coinbase" for assets. Only need RVN vins.
    var rvn_utxos = <Vout>[];
    var txb;
    var tx;
    var fee_sats = 0;
    var sats_returned = -1; // Init to bad val

    var return_address =
        services.wallet.getChangeWallet(wallet).address; // takes the longest

    var rebuild = true;
    while (sats_returned < 0 || rebuild) {
      rebuild = false; // must rebuild transaction at least once.
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN for fee
      rvn_utxos = services.balance.collectUTXOs(
        wallet,
        amount: (estimate.security == null ? estimate.amount : 0) + fee_sats,
        security: null,
      );

      var sats_in = 0;
      for (var utxo in rvn_utxos) {
        txb.addInput(utxo.transactionId, utxo.position);
        // Update avaliable RVN
        sats_in += utxo.rvnValue;
      }

      sats_returned =
          sats_in - res.settings.network.burnAmounts.issueMain - fee_sats;

      txb.generateCreateAssetVouts(
          newAssetToAddress,
          ownershipToAddress ?? newAssetToAddress,
          estimate.amount,
          estimate.security!.symbol,
          divisibility,
          reissuability,
          ipfsData);

      txb.addChangeToAssetCreationOrReissuance(
          2, return_address, sats_returned);
      // Add transaction memo if one is given
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo, offset: 2);
      }

      tx = txb.buildSpoofedSigs();
      fee_sats = tx.fee(goal);
    }
    txb.signEachInput(rvn_utxos);
    tx = txb.build();
    estimate.setFees(fee_sats);
    return Tuple2(tx, estimate);
  }

  Tuple2<ravencoin.Transaction, SendEstimate> transactionCreateSubAsset(
    String newAssetToAddress,
    String parentAsset,
    SendEstimate estimate,
    int divisibility,
    bool reissuability, {
    String? parentOwnershipToAddress,
    String? ownershipToAddress,
    Uint8List? ipfsData,
    required Wallet wallet,
    TxGoal? goal,
  }) {
    // This is a "coinbase" for assets. Only need RVN vins and ownership vin.
    var ownership_utxo = services.balance.collectUTXOs(
      wallet,
      amount: 100000000,
      security: Security(
          symbol: parentAsset + '!', securityType: SecurityType.RavenAsset),
    );
    if (ownership_utxo.isEmpty) {
      throw ArgumentError('We don\'t own the parent ownership asset!');
    }
    var rvn_utxos = <Vout>[];
    var txb;
    var tx;
    var fee_sats = 0;
    var sats_returned = -1; // Init to bad val

    var return_address =
        services.wallet.getChangeWallet(wallet).address; // takes the longest

    var rebuild = true;
    while (sats_returned < 0 || rebuild) {
      rebuild = false; // must rebuild transaction at least once.
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN for fee
      rvn_utxos = services.balance.collectUTXOs(
        wallet,
        amount: (estimate.security == null ? estimate.amount : 0) + fee_sats,
        security: null,
      );

      var sats_in = 0;
      for (var utxo in rvn_utxos + ownership_utxo) {
        txb.addInput(utxo.transactionId, utxo.position);
        // Update avaliable RVN
        sats_in += utxo.rvnValue;
      }

      sats_returned =
          sats_in - res.settings.network.burnAmounts.issueSub - fee_sats;

      txb.generateCreateSubAssetVouts(
          newAssetToAddress,
          ownershipToAddress ?? newAssetToAddress,
          parentOwnershipToAddress ?? return_address,
          estimate.amount,
          parentAsset,
          estimate.security!.symbol,
          divisibility,
          reissuability,
          ipfsData);

      txb.addChangeToAssetCreationOrReissuance(
          3, return_address, sats_returned);
      // Add transaction memo if one is given
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo, offset: 3);
      }

      tx = txb.buildSpoofedSigs();
      fee_sats = tx.fee(goal);
    }
    txb.signEachInput(rvn_utxos + ownership_utxo);
    tx = txb.build();
    estimate.setFees(fee_sats);
    return Tuple2(tx, estimate);
  }

  // Used for unique and message assets
  Tuple2<ravencoin.Transaction, SendEstimate> transactionCreateChildAsset(
    String newAssetToAddress,
    String parentAsset,
    SendEstimate estimate, {
    String? parentOwnershipToAddress,
    Uint8List? ipfsData,
    required Wallet wallet,
    TxGoal? goal,
  }) {
    // This is a "coinbase" for assets. Only need RVN vins and ownership vin.
    var ownership_utxo = services.balance.collectUTXOs(
      wallet,
      amount: 100000000,
      security: Security(
          symbol: parentAsset + '!', securityType: SecurityType.RavenAsset),
    );
    if (ownership_utxo.isEmpty) {
      throw ArgumentError('We don\'t own the parent ownership asset!');
    }
    var rvn_utxos = <Vout>[];
    var txb;
    var tx;
    var fee_sats = 0;
    var sats_returned = -1; // Init to bad val

    var return_address =
        services.wallet.getChangeWallet(wallet).address; // takes the longest

    var rebuild = true;
    while (sats_returned < 0 || rebuild) {
      rebuild = false; // must rebuild transaction at least once.
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN for fee
      rvn_utxos = services.balance.collectUTXOs(
        wallet,
        amount: (estimate.security == null ? estimate.amount : 0) + fee_sats,
        security: null,
      );

      var sats_in = 0;
      for (var utxo in rvn_utxos + ownership_utxo) {
        txb.addInput(utxo.transactionId, utxo.position);
        // Update avaliable RVN
        sats_in += utxo.rvnValue;
      }

      sats_returned = sats_in -
          (estimate.security!.symbol.contains('~')
              ? res.settings.network.burnAmounts.issueMessage
              : res.settings.network.burnAmounts.issueUnique) -
          fee_sats;

      txb.generateCreateSubAssetVouts(
          newAssetToAddress,
          parentOwnershipToAddress ?? return_address,
          parentAsset,
          estimate.security!.symbol,
          ipfsData);

      txb.addChangeToAssetCreationOrReissuance(
          2, return_address, sats_returned);
      // Add transaction memo if one is given
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo, offset: 2);
      }

      tx = txb.buildSpoofedSigs();
      fee_sats = tx.fee(goal);
    }
    txb.signEachInput(rvn_utxos + ownership_utxo);
    tx = txb.build();
    estimate.setFees(fee_sats);
    return Tuple2(tx, estimate);
  }

  Tuple2<ravencoin.Transaction, SendEstimate> transaction(
    String toAddress,
    SendEstimate estimate, {
    required Wallet wallet,
    TxGoal? goal,
  }) {
    ravencoin.TransactionBuilder? txb;
    ravencoin.Transaction tx;
    var fee_sats = 0;

    // Grab required assets for transfer amount
    var rvn_utxos = <Vout>[];
    var security_utxos = estimate.security != null
        ? services.balance.collectUTXOs(
            wallet,
            amount: estimate.amount,
            security: estimate.security,
          )
        : <Vout>[];

    var security_in = 0;
    for (var utxo in security_utxos) {
      security_in += utxo.assetValue!;
    }
    var security_change =
        estimate.security == null ? 0 : security_in - estimate.amount;

    var stopwatch = Stopwatch()..start();
    var return_address = services.wallet.getChangeAddress(wallet);
    print('getChangeWallet $return_address costs: ${stopwatch.elapsed}');

    var sats_returned = -1; // Init to bad val
    while (sats_returned < 0 || fee_sats != estimate.fees) {
      fee_sats = estimate.fees;
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN for fee (plus amount, maybe)
      rvn_utxos = services.balance.collectUTXOs(
        wallet,
        amount: fee_sats + (estimate.security == null ? estimate.amount : 0),
        security: null,
      );

      var sats_in = 0;
      for (var utxo in rvn_utxos) {
        txb.addInput(utxo.transactionId, utxo.position);
        // Update avaliable RVN
        sats_in += utxo.rvnValue;
      }

      sats_returned = sats_in -
          (estimate.security == null ? estimate.amount : 0) -
          fee_sats;

      // Add actual values
      txb.addOutput(
        toAddress, // mjQSgeVh5ZHfwGzBkiQcpr119Wh6QMyQ3b
        estimate.amount,
        asset: estimate.security?.symbol,
        memo: estimate.assetMemo?.hexBytes,
      );
      if (security_change > 0) {
        txb.addOutput(
          return_address, // n1tpotky5ybvsvYnMWwXzrrzDbX1X2pqsx
          security_change,
          asset: estimate.security!.symbol,
        );
      }
      if (sats_returned > 0) {
        txb.addOutput(return_address, sats_returned);
      }
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo);
      }
      var stopwatchSpoof = Stopwatch()..start();
      tx = txb.buildSpoofedSigs();
      print('spoof costs: ${stopwatchSpoof.elapsed}');
      estimate.setFees(tx.fee(goal: goal));
    }
    var stopwatchSign = Stopwatch()..start();
    txb!.signEachInput(rvn_utxos + security_utxos);
    print('signing costs: ${stopwatchSign.elapsed}');
    tx = txb.build();
    return Tuple2(tx, estimate);
  }

  Tuple2<ravencoin.Transaction, SendEstimate> transactionSendAll(
    String toAddress,
    SendEstimate estimate, {
    required Wallet wallet,
    TxGoal? goal,
  }) {
    var txb = ravencoin.TransactionBuilder(network: res.settings.network);
    var utxosOriginal = services.balance.sortedUnspents(
      wallet,
      security: estimate.security,
    );
    var total = 0;
    for (var utxo in utxosOriginal.toSet()) {
      txb.addInput(utxo.transactionId, utxo.position);
      total = total + utxo.securityValue(security: estimate.security);
    }
    if (estimate.memo != null) {
      txb.addMemo(estimate.memo);
    }
    estimate.setUTXOs(utxosOriginal);
    txb.addOutput(toAddress, estimate.amount);
    txb.signEachInput(utxosOriginal);
    var tx = txb.build();
    var fees = tx.fee(goal: goal);
    estimate.setFees(tx.fee(goal: goal));
    estimate.setAmount(total - fees);
    var satsIn =
        utxosOriginal.fold(0, (int total, vout) => total + vout.rvnValue);
    var satsReturn =
        satsIn - (estimate.security == null ? estimate.amount : 0) - fees;
    var return_address = services.wallet.getChangeWallet(wallet).address;
    var rebuild = true;
    while (satsReturn < 0 || rebuild) {
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      List<Vout> rvn_utxos;
      List<Vout> security_utxos;
      if (estimate.security != null) {
        // Grab required RVN for fee
        rvn_utxos = services.balance.collectUTXOs(
          wallet,
          amount: fees,
          security: null,
        );
        security_utxos =
            utxosOriginal.where((utxo) => !rvn_utxos.contains(utxo)).toList();
      } else {
        rvn_utxos = [];
        security_utxos = utxosOriginal;
      }
      var utxos = (rvn_utxos + security_utxos).toSet();

      for (var utxo in utxos) {
        txb.addInput(utxo.transactionId, utxo.position);
      }
      // Update avaliable RVN
      satsIn = utxos.fold(0, (int total, vout) => total + vout.rvnValue);
      satsReturn =
          satsIn - (estimate.security == null ? estimate.amount : 0) - fees;
      // Add actual values
      txb.addOutput(return_address, satsReturn);
      txb.addOutput(
        toAddress,
        estimate.amount,
        asset: estimate.security?.symbol,
        memo: estimate.assetMemo?.hexBytes,
      );
      // Add transaction memo if one is given
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo);
      }
      txb.signEachInput(utxos.toList());
      tx = txb.build();
      fees = tx.fee(goal: goal);
    }
    estimate.setFees(fees);
    return Tuple2(tx, estimate);
  }

  Tuple2<ravencoin.Transaction, SendEstimate> transactionSendAllRVN(
    String toAddress,
    SendEstimate estimate, {
    required Wallet wallet,
    TxGoal? goal,
    Set<int>? previousFees,
    Security? security,
  }) {
    previousFees = previousFees ?? {};
    var txb = ravencoin.TransactionBuilder(network: res.settings.network);
    var utxos = services.balance.sortedUnspents(wallet);
    var total = 0;
    for (var utxo in utxos) {
      txb.addInput(utxo.transactionId, utxo.position);
      total = total + utxo.securityValue(security: security);
    }
    var updatedEstimate = SendEstimate.copy(estimate)..setUTXOs(utxos);
    txb.addOutput(toAddress, estimate.amount);
    txb.signEachInput(utxos);
    var tx = txb.build();
    var fees = tx.fee(goal: goal);
    updatedEstimate.setFees(tx.fee(goal: goal));
    updatedEstimate.setAmount(total - fees);
    if (previousFees.contains(fees)) {
      return Tuple2(tx, updatedEstimate);
    } else {
      return transactionSendAllRVN(
        toAddress,
        updatedEstimate,
        goal: goal,
        wallet: wallet,
        previousFees: {...previousFees, fees},
        security: security,
      );
    }
  }
}
