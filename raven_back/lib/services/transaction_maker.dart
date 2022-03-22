import 'dart:typed_data';

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
    ravencoin.TransactionBuilder? txb;
    ravencoin.Transaction tx;
    var feeSats = 0;
    // Grab required assets for transfer amount
    var utxosRaven = <Vout>[];
    var utxosSecurity = services.balance.collectUTXOs(wallet,
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
      utxosRaven = services.balance.collectUTXOs(
        wallet,
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
          newAssetToAddress,
          ownershipToAddress ?? newAssetToAddress,
          currentSatsInCirculation,
          estimate.amount,
          estimate.security!.symbol,
          originalDivisibility,
          newDivisibility,
          reissuability,
          ipfsData);

      // This inserts change in a valid index
      if (returnRaven > 0) {
        txb.addChangeToAssetCreationOrReissuance(2, returnAddress, returnRaven);
      }

      // This inserts a memo in a valid index
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo, offset: 2);
      }
      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: goal));
    }
    txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
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
      utxosRaven = services.balance.collectUTXOs(
        wallet,
        amount: feeSats + res.settings.network.burnAmounts.issueMain,
        security: null,
      );
      var satsIn = 0;
      for (var utxo in utxosRaven) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.rvnValue;
      }
      returnRaven =
          satsIn - res.settings.network.burnAmounts.issueMain - feeSats;

      txb.generateCreateAssetVouts(
          newAssetToAddress,
          ownershipToAddress ?? newAssetToAddress,
          estimate.amount,
          estimate.security!.symbol,
          divisibility,
          reissuability,
          ipfsData);

      if (returnRaven > 0) {
        txb.addChangeToAssetCreationOrReissuance(2, returnAddress, returnRaven);
      }
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo, offset: 2);
      }
      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: goal));
    }
    txb!.signEachInput(utxosRaven);
    tx = txb.build();
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
    ravencoin.TransactionBuilder? txb;
    ravencoin.Transaction tx;
    var feeSats = 0;
    // Grab required assets for transfer amount
    var utxosRaven = <Vout>[];
    // 1 virtual ownership asset for the parent
    var utxosSecurity = estimate.security != null
        ? services.balance.collectUTXOs(wallet,
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
      utxosRaven = services.balance.collectUTXOs(
        wallet,
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
          newAssetToAddress,
          ownershipToAddress ?? newAssetToAddress,
          parentOwnershipToAddress ?? returnAddress,
          estimate.amount,
          parentAsset,
          estimate.security!.symbol,
          divisibility,
          reissuability,
          ipfsData);
      if (returnRaven > 0) {
        txb.addChangeToAssetCreationOrReissuance(3, returnAddress, returnRaven);
      }
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo, offset: 3);
      }
      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: goal));
    }
    txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
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
    ravencoin.TransactionBuilder? txb;
    ravencoin.Transaction tx;
    var feeSats = 0;
    // Grab required assets for transfer amount
    var utxosRaven = <Vout>[];
    // 1 virtual ownership asset for the parent
    var utxosSecurity = estimate.security != null
        ? services.balance.collectUTXOs(wallet,
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
      // Grab required RVN for fee plus burn
      utxosRaven = services.balance.collectUTXOs(
        wallet,
        amount: feeSats +
            (estimate.security!.symbol.contains('~')
                ? res.settings.network.burnAmounts.issueMessage
                : res.settings.network.burnAmounts.issueUnique),
        security: null,
      );
      var satsIn = 0;
      for (var utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.rvnValue;
      }
      returnRaven = satsIn -
          (estimate.security!.symbol.contains('~')
              ? res.settings.network.burnAmounts.issueMessage
              : res.settings.network.burnAmounts.issueUnique) -
          feeSats;
      txb.generateCreateChildAssetVouts(
          newAssetToAddress,
          parentOwnershipToAddress ?? returnAddress,
          parentAsset,
          estimate.security!.symbol,
          ipfsData);
      if (returnRaven > 0) {
        txb.addChangeToAssetCreationOrReissuance(2, returnAddress, returnRaven);
      }
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo, offset: 2);
      }
      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: goal));
    }
    txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
    return Tuple2(tx, estimate);
  }

  Tuple2<ravencoin.Transaction, SendEstimate> transactionBroadcastMessage(
    SendEstimate estimate, {
    required Wallet wallet,
    TxGoal? goal,
  }) {
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
    var utxosSecurity = services.balance
        .collectUTXOs(wallet, amount: 100000000, security: estimate.security!);
    var returnAddress = services.wallet.getChangeAddress(wallet);
    var returnRaven = -1; // Init to bad val
    while (returnRaven < 0 || feeSats != estimate.fees) {
      feeSats = estimate.fees;
      txb = ravencoin.TransactionBuilder(network: res.settings.network);
      // Grab required RVN for fee plus burn
      utxosRaven = services.balance.collectUTXOs(
        wallet,
        amount: feeSats,
        security: null,
      );
      var satsIn = 0;
      for (var utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.rvnValue;
      }
      returnRaven = satsIn - feeSats;

      // Sends the asset to the address currently holding it with a message
      txb.addOutput(
        utxosRaven.first.toAddress,
        100000000,
        asset: estimate.security!.symbol,
        memo: estimate.assetMemo!.hexBytes,
      );

      if (returnRaven > 0) {
        txb.addOutput(returnAddress, returnRaven);
      }

      if (estimate.memo != null) {
        txb.addMemo(estimate.memo);
      }
      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: goal));
    }
    txb!.signEachInput(utxosRaven + utxosSecurity);
    tx = txb.build();
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
    var feeSats = 0;
    // Grab required assets for transfer amount
    var utxosRaven = <Vout>[];
    var utxosSecurity = estimate.security != null
        ? services.balance.collectUTXOs(
            wallet,
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
      utxosRaven = services.balance.collectUTXOs(
        wallet,
        amount: feeSats + (estimate.security == null ? estimate.amount : 0),
        security: null,
      );
      var satsIn = 0;
      // We also add inputs in this loop
      for (var utxo in utxosRaven + utxosSecurity) {
        txb.addInput(utxo.transactionId, utxo.position);
        satsIn += utxo.rvnValue;
      }
      returnRaven =
          satsIn - (estimate.security == null ? estimate.amount : 0) - feeSats;
      txb.addOutput(
        toAddress,
        estimate.amount,
        asset: estimate.security?.symbol,
        memo: estimate.assetMemo?.hexBytes,
      );
      if (securityChange > 0) {
        txb.addOutput(
          returnAddress,
          securityChange,
          asset: estimate.security!.symbol,
        );
      }
      if (returnRaven > 0) {
        txb.addOutput(returnAddress, returnRaven);
      }
      if (estimate.memo != null) {
        txb.addMemo(estimate.memo);
      }
      tx = txb.buildSpoofedSigs();
      estimate.setFees(tx.fee(goal: goal));
    }
    txb!.signEachInput(utxosRaven + utxosSecurity);
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
