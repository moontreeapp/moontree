import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:client_back/records/types/transaction_view.dart';
import 'package:client_back/server/src/protocol/comm_transaction_view.dart';
import 'package:tuple/tuple.dart';
import 'package:date_format/src/date_format_base.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart' as wallet_utils;
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/spend.dart';

import 'maker.dart';

extension TransactionViewMethods on TransactionView {
  String? get note => pros.notes.primaryIndex.getOne(readableHash)?.note;
  String get readableHash => hash.toHex();

  Security? get security => symbol == null
      ? pros.securities.currentCoin
      : pros.securities.byKey
          .getOne(symbol, pros.settings.chain, pros.settings.net);

  Chaindata get chaindata => ChainNet.from(name: chain).chaindata;

  /// true is outgoing false is incoming
  bool get outgoing => (iReceived - iProvided) <= 0;
  double get amount => iValue.asCoin;
  bool get isNormal => false;

  /// always positive
  /// replaced by fee
  //int get txFee => totalIn - (iReceived + otherReceived + totalBurn);

  double get feeRate => fee / vsize;

  /// always positive
  //bool get iPaidTxFee => otherProvided == 0;
  bool get iPaidFee => iProvided > 0;

  //int get totalIn => (iProvided + otherProvided);
  //int get totalOut => (iReceived + otherReceived) + txFee + totalBurn;

  int get iValue => (iReceived - iProvided).abs();

  //int get iFee => iPaidTxFee ? txFee : 0;
  int get iFee => iPaidFee ? fee : 0;

  //int get relativeValue =>
  //    type == TransactionViewType.self ? iProvided : (iValue - iFee);
  //int get relativeValue =>
  //    type == TransactionViewType.self ? iReceived : iValue;
  /// just the total that went away or came in
  int get totalValue => outgoing ? iProvided : iReceived;
  int get iValueTotal => [
        TransactionViewType.self,
        TransactionViewType.consolidation
      ].contains(type)
          ? iReceived
          : iValue;

  /// iValue and sent to self on assets always shows 0 since tx fees are in the base currency...
  /// Using iReceived is not technically any better because it just reflects the
  /// particular inputs we used, not what we specified to send, but at least
  /// it's a number rather than 0, and this is an edge case where nobody but us
  /// testers will be sending assets to addresses they already own...
  //int get iValueTotal =>
  //    type == TransactionViewType.self && !isCoin ? iReceived : iValue;
  /// actually, we should just show the total in any case to remain consistent.
  //int get iValueTotal => iValue;
  /// actually it feels more consistent to user if they see the total they sent
  /// on a sent to self, with a special icon, so reverting

  bool get sentToSelf => iProvided == iReceived + (isCoin ? fee : 0);

  bool get consolidationToSelf =>
      sentToSelf &&
      false; /*&& more than one vout of the same asset type went into this transaction */

  bool get onlyFee => isCoin && (iProvided - iReceived) == fee;

  bool get isCoin => security?.isCoin ?? false;

  int get totalBurn =>
      burnBurned +
      issueMainBurned +
      reissueBurned +
      issueSubBurned +
      issueUniqueBurned +
      issueMessageBurned +
      issueQualifierBurned +
      issueSubQualifierBurned +
      issueRestrictedBurned +
      addTagBurned;

  /// asset creation, reissue, send, etc.
  /// did we sent to burn address? only sent to self?
  TransactionViewType get type {
    // For a more comprehensive check, we should make sure new assets vouts
    // actually exist. also how would this work for assets?
    TransactionViewType? burned() {
      if (isCoin) {
        // Must be == not ge, if ge, normal burn since assets are exact
        if (issueMainBurned == chaindata.burnAmounts.issueMain) {
          return TransactionViewType.createAsset;
        }
        if (reissueBurned == chaindata.burnAmounts.reissue) {
          return TransactionViewType.reissue;
        }
        if (issueSubBurned == chaindata.burnAmounts.issueSub) {
          return TransactionViewType.createSubAsset;
        }
        if (issueUniqueBurned == chaindata.burnAmounts.issueUnique) {
          return TransactionViewType.createNFT;
        }
        if (issueMessageBurned == chaindata.burnAmounts.issueMessage) {
          return TransactionViewType.createMessage;
        }
        if (issueQualifierBurned == chaindata.burnAmounts.issueQualifier) {
          return TransactionViewType.createQualifier;
        }
        if (issueSubQualifierBurned ==
            chaindata.burnAmounts.issueSubQualifier) {
          return TransactionViewType.createSubQualifier;
        }
        if (issueRestrictedBurned == chaindata.burnAmounts.issueRestricted) {
          return TransactionViewType.createRestricted;
        }
        if (addTagBurned == chaindata.burnAmounts.addTag) {
          return TransactionViewType.tag;
        }
      }
      if (totalBurn > 0) {
        return TransactionViewType.burn;
      }
      return null;
    }

    final regular = sentToSelf
        ? consolidationToSelf
            ? TransactionViewType.consolidation
            : (isCoin && !containsAssets) || !isCoin
                ? TransactionViewType.self
                : TransactionViewType.assetTransaction
        : iValue > 0
            ? TransactionViewType.incoming
            : TransactionViewType.outgoing;
    final burn = burned();
    return burn ?? regular;
  }

  String get formattedDatetime =>
      formatDate(datetime, <String>[MM, ' ', d, ', ', yyyy]);
}

class TransactionViewSpoof {
  TransactionViewSpoof({
    this.symbol,
    required this.chain,
    required this.hash,
    required this.datetime,
    required this.height,
    required this.iProvided,
    required this.otherProvided,
    required this.iReceived,
    required this.otherReceived,
    required this.issueMainBurned,
    required this.reissueBurned,
    required this.issueSubBurned,
    required this.issueUniqueBurned,
    required this.issueMessageBurned,
    required this.issueQualifierBurned,
    required this.issueSubQualifierBurned,
    required this.issueRestrictedBurned,
    required this.addTagBurned,
    required this.burnBurned,
  });

  String? symbol;
  String chain;
  ByteData hash;
  DateTime datetime;
  int height;
  int iProvided;
  int otherProvided;
  int iReceived;
  int otherReceived;
  int issueMainBurned;
  int reissueBurned;
  int issueSubBurned;
  int issueUniqueBurned;
  int issueMessageBurned;
  int issueQualifierBurned;
  int issueSubQualifierBurned;
  int issueRestrictedBurned;
  int addTagBurned;
  int burnBurned;
}

class TransactionService {
  final TransactionMaker make = TransactionMaker();

  List<Vout> walletUnspents(Wallet wallet, {Security? security}) =>
      VoutProclaim.whereUnspent(
              given: wallet.vouts,
              security: security ?? pros.securities.currentCoin,
              includeMempool: false)
          .toList();

  Transaction? getTransactionFrom({Transaction? transaction, String? hash}) {
    transaction ??
        hash ??
        (() => throw OneOfMultipleMissing(
            'transaction or hash required to identify record.'))();
    return transaction ?? pros.transactions.primaryIndex.getOne(hash ?? '');
  }

  List<TransactionViewSpoof> getTransactionViewSpoof({
    required Wallet wallet,
    Set<Security>? securities,
  }) {
    final views = <TransactionViewSpoof>[
      TransactionViewSpoof(
          // send transaction
          symbol: 'RVN',
          chain: 'ravencoin_mainnet',
          hash: ByteData(0),
          datetime: DateTime.now(),
          height: 0,
          iProvided: 27 * wallet_utils.satsPerCoin,
          otherProvided: 4 * wallet_utils.satsPerCoin,
          iReceived: 20 * wallet_utils.satsPerCoin,
          otherReceived: 10 * wallet_utils.satsPerCoin,
          issueMainBurned: 0,
          reissueBurned: 0,
          issueSubBurned: 0,
          issueUniqueBurned: 0,
          issueMessageBurned: 0,
          issueQualifierBurned: 0,
          issueSubQualifierBurned: 0,
          issueRestrictedBurned: 0,
          addTagBurned: 0,
          burnBurned: 0),
      TransactionViewSpoof(
          // send transaction
          symbol: 'RVN',
          chain: 'ravencoin_mainnet',
          hash: ByteData(0),
          datetime: DateTime.now(),
          height: 0,
          iProvided: 27 * wallet_utils.satsPerCoin,
          otherProvided: 0,
          iReceived: 19 * wallet_utils.satsPerCoin,
          otherReceived: 7 * wallet_utils.satsPerCoin,
          issueMainBurned: 0,
          reissueBurned: 0,
          issueSubBurned: 0,
          issueUniqueBurned: 0,
          issueMessageBurned: 0,
          issueQualifierBurned: 0,
          issueSubQualifierBurned: 0,
          issueRestrictedBurned: 0,
          addTagBurned: 0,
          burnBurned: 0),
      TransactionViewSpoof(
          // receive
          symbol: 'RVN',
          chain: 'ravencoin_mainnet',
          hash: ByteData(0),
          datetime: DateTime.now(),
          height: 0,
          iProvided: 1 * wallet_utils.satsPerCoin,
          otherProvided: 26 * wallet_utils.satsPerCoin,
          iReceived: 26 * wallet_utils.satsPerCoin,
          otherReceived: 0,
          issueMainBurned: 0,
          reissueBurned: 0,
          issueSubBurned: 0,
          issueUniqueBurned: 0,
          issueMessageBurned: 0,
          issueQualifierBurned: 0,
          issueSubQualifierBurned: 0,
          issueRestrictedBurned: 0,
          addTagBurned: 0,
          burnBurned: 0),
      TransactionViewSpoof(
          // sent to self
          symbol: 'RVN',
          chain: 'ravencoin_mainnet',
          hash: ByteData(0),
          datetime: DateTime.now(),
          height: 0,
          iProvided: 27 * wallet_utils.satsPerCoin,
          otherProvided: 0,
          iReceived: 26 * wallet_utils.satsPerCoin,
          otherReceived: 0,
          issueMainBurned: 0,
          reissueBurned: 0,
          issueSubBurned: 0,
          issueUniqueBurned: 0,
          issueMessageBurned: 0,
          issueQualifierBurned: 0,
          issueSubQualifierBurned: 0,
          issueRestrictedBurned: 0,
          addTagBurned: 0,
          burnBurned: 0),
      TransactionViewSpoof(
          // asset creation
          symbol: 'RVN',
          chain: 'ravencoin_mainnet',
          hash: ByteData(1),
          datetime: DateTime.now(),
          height: 1,
          iProvided: 600 * wallet_utils.satsPerCoin,
          otherProvided: 0,
          iReceived: 99 * wallet_utils.satsPerCoin,
          otherReceived: 0,
          issueMainBurned: 500 * wallet_utils.satsPerCoin,
          reissueBurned: 0,
          issueSubBurned: 0,
          issueUniqueBurned: 0,
          issueMessageBurned: 0,
          issueQualifierBurned: 0,
          issueSubQualifierBurned: 0,
          issueRestrictedBurned: 0,
          addTagBurned: 0,
          burnBurned: 0),
    ];
    return views;
  }

  /// for each transaction
  ///   get a list of all securities involved on vins.vouts and vouts
  ///   for each security involed
  ///     transaction record: sum vins - some vouts
  /// return transaction records
  List<TransactionRecord> getTransactionRecords({
    required Wallet wallet,
    Set<Security>? securities,
  }) {
    /// if we see tx not all downloaded add a blank record onto the end...
    //if (!services.download.history.transactionsDownloaded()) {
    //  return <TransactionRecord>[];
    //}
    final Set<String> givenAddresses =
        wallet.addressesFor().map((Address address) => address.address).toSet();
    final List<TransactionRecord> transactionRecords = <TransactionRecord>[];
    final Security currentCrypto = pros.securities.currentCoin;

    final wallet_utils.NetworkType net = pros.settings.chainNet.network;
    final Map<String, int> specialTag = <String, int>{
      net.burnAddresses.addTag: net.burnAmounts.addTag
    };
    final Map<String, int> specialReissue = <String, int>{
      net.burnAddresses.reissue: net.burnAmounts.reissue
    };
    final Map<String, int> specialCreate = <String, int>{
      net.burnAddresses.issueMain: net.burnAmounts.issueMain,
      net.burnAddresses.issueMessage: net.burnAmounts.issueMessage,
      net.burnAddresses.issueQualifier: net.burnAmounts.issueQualifier,
      net.burnAddresses.issueRestricted: net.burnAmounts.issueRestricted,
      net.burnAddresses.issueSub: net.burnAmounts.issueSub,
      net.burnAddresses.issueSubQualifier: net.burnAmounts.issueSub,
      net.burnAddresses.issueSubQualifier: net.burnAmounts.issueSubQualifier,
      net.burnAddresses.issueUnique: net.burnAmounts.issueUnique
    };
    for (final Transaction transaction in pros.transactions.chronological) {
      final Set<Security?> securitiesInvolved = ((transaction.vins
                  .where((Vin vin) =>
                      givenAddresses.contains(vin.vout?.toAddress) &&
                      vin.vout?.security != null)
                  .map((Vin vin) => vin.vout?.security)
                  .toList()) +
              (transaction.vouts
                  .where((Vout vout) =>
                      givenAddresses.contains(vout.toAddress) &&
                      vout.security != null)
                  .map((Vout vout) => vout.security)
                  .toList()))
          .toSet();
      for (final Security? security in securitiesInvolved) {
        if (securities == null || securities.contains(security)) {
          // from other to me: selfIn = 0
          //   other in and self in is totalin
          //   self out is total
          //   other out is change
          //   totalin - (totalout +change ) is fee
          // from me to other: otherOut != 0
          //   other in and self in is totalin
          //   self out is change
          //   other out is total
          //   totalin - (totalout +change ) is fee
          // from me to me: otherOut = 0
          //   other in and self in is totalin
          //   self out is change and total
          //   totalin - (total) is fee
          // from other to other:
          //   we don't keep record of that.

          // This is only used for checking special addresses
          // This will never contain our own addrs
          final Map<String, int> outgoingAddrs = <String, int>{};

          if (security == currentCrypto) {
            int selfIn = 0;
            int othersIn = 0;
            int selfOut = 0;
            int othersOut = 0;

            // self out can be broken into two categories based on the address it was sent to
            int outIntentional = 0;
            // ignore: unused_local_variable
            int outChange = 0; // actually used.
            bool feeFlag = false;

            int totalInRVN = 0;
            int totalOutRVN = 0;
            TransactionViewType? ioType;
            // Nothing too special about incoming...
            for (final Vin vin in transaction.vins) {
              /// #651 I wonder if at this point there isn't a vout associated
              /// with the vin because vouts are still downloading... maybe
              /// that's the root cause of the transactions displaying wrong
              /// fee the first time transactions are viewed immediately after
              /// importing the wallet on occasion... (not proven replicable
              /// yet)... but if that's it we might should not allow users to
              /// click transactions until vouts are fully downloaded... having
              /// disabled vouts to test this theory we're unable to see
              /// transactions at all until vouts are downloaded... so that's
              /// probably not it... we'll wait till the issue surfaces again.
              final Vout? vinVout = vin.vout;

              /// we have another issue when it comes to the claim process:
              /// we don't download the genesis block of the EVR chain so we do
              /// not have the vout that those claim transactions point to. so
              /// we have a special case for that here.

              if (vin.voutTransactionId == wallet_utils.evrAirdropTx) {
                //print(pros.unspents.records);
                //print(vin.transactionId);
                //var value = pros.unspents.records
                //    .where((u) => u.transactionId == vin.transactionId)
                //    .fold(0,
                //        (int? running, Unspent u) => u.value + (running ?? 0));
                //selfIn += value;
                //totalInRVN += value;
                //feeFlag = true;
                //
                /// getting the utxos is a special case, instead we should use vouts:
                //var utxos = pros.unspents.records
                //    .where((u) => u.transactionId == vin.transactionId);
                //Unspent utxo;
                //if (utxos.isNotEmpty) {
                //  utxo = utxos.first;
                //  vinVout = Vout.fromUnspent(utxo,
                //      //simulate fee since it's hard to determin for claims
                //      rvnValue: utxo.value - 211200,
                //      toAddress: //utxo.address?.address ??
                //          pros.addresses.byScripthash
                //              .getOne(utxo.scripthash)
                //              ?.address);
                //}
                /// this isn't the right Vout, we don't capture it, bigger issue
                //final txVouts =
                //    pros.vouts.byTransaction.getAll(vin.transactionId);
                //if (txVouts.length == 1) {
                //  vinVout = txVouts.first;
                //} else if (txVouts.isNotEmpty) {}
                /// for now just not doing anyting, this only to deduce fee anyway.
                ioType ??= TransactionViewType.claim;
              }
              if (vinVout == null) {
                /// unable to await so set flag
                //services.download.history
                //    .getAndSaveTransactions({vin.voutTransactionId});
                feeFlag = true;
              }
              if ((vinVout?.security ?? currentCrypto) == currentCrypto) {
                if (givenAddresses.contains(vinVout?.toAddress)) {
                  selfIn += vinVout?.coinValue ?? 0;
                } else {
                  othersIn += vinVout?.coinValue ?? 0;
                }
                totalInRVN += vinVout?.coinValue ?? 0;
              }
            }

            for (final Vout vout in transaction.vouts) {
              if (vout.security == currentCrypto) {
                totalOutRVN += vout.coinValue;
                if (givenAddresses.contains(vout.toAddress)) {
                  selfOut += vout.coinValue;
                  if (wallet.internalAddresses
                      .map((Address a) => a.address)
                      .contains(vout.toAddress)) {
                    outChange += vout.coinValue;
                  } else {
                    outIntentional += vout.coinValue;
                  }
                } else {
                  othersOut += vout.coinValue;
                  if (specialCreate.containsKey(vout.toAddress) ||
                      specialReissue.containsKey(vout.toAddress) ||
                      specialTag.containsKey(vout.toAddress) ||
                      vout.toAddress == net.burnAddresses.burn) {
                    final int current = outgoingAddrs[vout.toAddress!] ?? 0;
                    outgoingAddrs[vout.toAddress!] = current + vout.coinValue;
                  }
                }
              }
            }

            final int fee = (selfIn + othersIn) - (selfOut + othersOut) ==
                    (selfIn + othersIn)
                ? totalInRVN - totalOutRVN
                : (selfIn + othersIn) - (selfOut + othersOut);

            // Known burn addr for tagging
            // This goes first as tags can also be in creations

            // TODO: Better verification; see if actual valid asset vouts exist

            final Set<String> tagIntersection = outgoingAddrs.keys
                .toSet()
                .intersection(specialTag.keys.toSet());
            if (tagIntersection.isNotEmpty) {
              for (final String address in tagIntersection) {
                if (outgoingAddrs[address] == specialTag[address]) {
                  ioType = TransactionViewType.tag;
                }
              }
              // If not a tag, effectively a burn
              ioType ??= TransactionViewType.burn;
            }

            final Set<String> reissueIntersection = outgoingAddrs.keys
                .toSet()
                .intersection(specialReissue.keys.toSet());
            if (reissueIntersection.isNotEmpty) {
              for (final String address in reissueIntersection) {
                if (outgoingAddrs[address] == specialReissue[address]) {
                  ioType = TransactionViewType.reissue;
                }
              }
              // If not a tag, effectively a burn
              ioType ??= TransactionViewType.burn;
            }

            final Set<String> createIntersection = outgoingAddrs.keys
                .toSet()
                .intersection(specialCreate.keys.toSet());
            // Known burn addr for creation
            if (createIntersection.isNotEmpty) {
              for (final String address in createIntersection) {
                if (outgoingAddrs[address] == specialCreate[address]) {
                  ioType = TransactionViewType.create;
                }
              }
              // If not a tag, effectively a burns
              ioType ??= TransactionViewType.burn;
            }

            // Only call it "sent to self" if no RVN is coming from anywhere else
            //if (othersIn == 0 && othersOut == 0 && selfIn > 0 && selfOut > 0) {
            // if no input from others, and everything spend is everything received
            // then it's sent to self, unless we're looking at ravencoin, in that case
            // maybe this was just a fee to send an asset, in that case, its just a
            // regular out transaction...
            if (transaction.vouts
                .map((Vout e) => !e.isAsset)
                .every((bool e) => e)) {
              if (othersIn == 0 && othersOut == 0 && selfIn == selfOut + fee) {
                if (ioType != TransactionViewType.claim) {
                  ioType = TransactionViewType.self;
                }
              }
            } else {
              ioType ??= TransactionViewType.fee;
            }
            if (selfIn > 0 &&
                outgoingAddrs.containsKey(net.burnAddresses.burn)) {
              ioType = TransactionViewType.burn;
            }
            // Defaults
            ioType ??= selfIn > selfOut
                ? TransactionViewType.outgoing
                : TransactionViewType.incoming;

            //print('s $selfIn $selfOut o $othersIn $othersOut');
            transactionRecords.add(TransactionRecord(
              transaction: transaction,
              security: security!,
              totalIn: selfIn,
              totalOut: selfOut,
              valueOverride: <TransactionViewType>[
                TransactionViewType.self,
                TransactionViewType.claim
              ].contains(ioType)
                  ? outIntentional
                  : null,
              height: transaction.height,
              type: ioType,
              fee: feeFlag ||
                      fee < (-1) * 1502 * wallet_utils.satsPerCoin ||
                      fee > 1502 * wallet_utils.satsPerCoin
                  ? 0
                  : fee,
              formattedDatetime: transaction.formattedDatetime,
            ));
          } else {
            int selfIn = 0;
            int selfInRVN = 0;
            int othersIn = 0;
            int othersInRVN = 0;

            int selfOut = 0;
            int selfOutRVN = 0;
            int othersOut = 0;
            int othersOutRVN = 0;
            // self out can be broken into two categories based on the address it was sent to
            int outIntentional = 0;
            // ignore: unused_local_variable
            int outChange = 0; // used
            bool feeFlag = false;

            // Nothing too special about incoming...
            for (final Vin vin in transaction.vins) {
              Vout? vinVout = vin.vout;
              if (vinVout == null) {
                /// unable to await so set flag
                //services.download.history
                //    .getAndSaveTransactions({vin.voutTransactionId});
                feeFlag = true;
              }
              vinVout = vin.vout;
              if (vinVout?.security == currentCrypto) {
                if (givenAddresses.contains(vinVout?.toAddress)) {
                  selfInRVN += vinVout?.coinValue ?? 0;
                } else {
                  othersInRVN += vinVout?.coinValue ?? 0;
                }
              } else if (vinVout?.security == security) {
                if (givenAddresses.contains(vinVout?.toAddress)) {
                  selfIn += vinVout?.assetValue ?? 0;
                } else {
                  othersIn += vinVout?.assetValue ?? 0;
                }
              }
            }

            for (final Vout vout in transaction.vouts) {
              if (vout.security == currentCrypto) {
                if (givenAddresses.contains(vout.toAddress)) {
                  selfOutRVN += vout.coinValue;
                } else {
                  othersOutRVN += vout.coinValue;
                  if (specialCreate.containsKey(vout.toAddress) ||
                      specialReissue.containsKey(vout.toAddress) ||
                      specialTag.containsKey(vout.toAddress) ||
                      vout.toAddress == net.burnAddresses.burn) {
                    final int current = outgoingAddrs[vout.toAddress!] ?? 0;
                    outgoingAddrs[vout.toAddress!] = current + vout.coinValue;
                  }
                }
              } else if (vout.security == security) {
                if (givenAddresses.contains(vout.toAddress)) {
                  selfOut += vout.assetValue ?? 0;
                  if (wallet.internalAddresses
                      .map((Address a) => a.address)
                      .contains(vout.toAddress)) {
                    outChange += vout.assetValue ?? 0;
                  } else {
                    outIntentional += vout.assetValue ?? 0;
                  }
                } else {
                  othersOut += vout.assetValue ?? 0;
                }
              }
            }

            TransactionViewType? ioType;

            // Known burn addr for tagging
            // This goes first as tags can also be in creations

            // TODO: Better verification; see if actual valid asset vouts exist

            final Set<String> tagIntersection = outgoingAddrs.keys
                .toSet()
                .intersection(specialTag.keys.toSet());
            if (tagIntersection.isNotEmpty) {
              for (final String address in tagIntersection) {
                if (outgoingAddrs[address] == specialTag[address]) {
                  ioType = TransactionViewType.tag;
                }
              }
              // If not a tag, effectively a burn
              ioType ??= TransactionViewType.burn;
            }

            final Set<String> reissueIntersection = outgoingAddrs.keys
                .toSet()
                .intersection(specialReissue.keys.toSet());
            if (reissueIntersection.isNotEmpty) {
              for (final String address in reissueIntersection) {
                if (outgoingAddrs[address] == specialReissue[address]) {
                  ioType = TransactionViewType.reissue;
                }
              }
              // If not a tag, effectively a burn
              ioType ??= TransactionViewType.burn;
            }

            final Set<String> createIntersection = outgoingAddrs.keys
                .toSet()
                .intersection(specialCreate.keys.toSet());
            // Known burn addr for creation
            if (createIntersection.isNotEmpty) {
              for (final String address in createIntersection) {
                if (outgoingAddrs[address] == specialCreate[address]) {
                  ioType = TransactionViewType.create;
                }
              }
              // If not a tag, effectively a burns
              ioType ??= TransactionViewType.burn;
            }

            // Only call it "sent to self" if no RVN is coming from anywhere else
            if (othersIn == 0 && othersOut == 0 && selfIn == selfOut) {
              ioType = TransactionViewType.self;
            }
            if (selfIn > 0 &&
                outgoingAddrs.containsKey(net.burnAddresses.burn)) {
              ioType = TransactionViewType.burn;
            }
            // Defaults
            ioType ??= selfIn > selfOut
                ? TransactionViewType.outgoing
                : TransactionViewType.incoming;

            transactionRecords.add(TransactionRecord(
              transaction: transaction,
              security: security!,
              totalIn: selfIn,
              totalOut: selfOut,
              valueOverride: <TransactionViewType>[
                TransactionViewType.self,
              ].contains(ioType)
                  ? outIntentional
                  : null,
              height: transaction.height,
              type: ioType,
              fee: feeFlag
                  ? 0
                  : (selfInRVN + othersInRVN) - (selfOutRVN + othersOutRVN),
              formattedDatetime: transaction.formattedDatetime,
            ));
          }
        }
      }
    }
    final List<TransactionRecord> ret = <TransactionRecord>[];
    final List<TransactionRecord> actual = <TransactionRecord>[];
    for (final TransactionRecord txRecord in transactionRecords) {
      if (txRecord.formattedDatetime == 'In Transit') {
        ret.add(txRecord);
      } else {
        actual.add(txRecord);
      }
    }
    ret.addAll(actual);
    return ret;
  }

  /// sweep all assets and crypto from one wallet to another
  Future<Set<Vout>> sweep({
    required Wallet from,
    required String toWalletId,
    required bool currency,
    required bool assets,
    String? memo,
    String? note,
    String? msg,
    int limit = 1000,
    Set<Vout>? usedUTXOs,
    bool incremental = false,
  }) async {
    usedUTXOs = usedUTXOs ?? <Vout>{};
    final String destinationAddress = services.wallet.getEmptyAddress(
      pros.wallets.primaryIndex.getOne(toWalletId)!,
      NodeExposure.external,
    );
    final List<Balance> assetBalances = from.balances
        .where((Balance b) => !pros.securities.coins.contains(b.security))
        .toList();

    if (from.unspents.isEmpty || from.coinValue == 0) {
      // unable to perform any transactions
      return usedUTXOs;
    }

    if (assets &&
        assetBalances.isNotEmpty &&
        assetBalances.fold(0, (int agg, Balance e) => e.value + agg) > 0) {
      if (currency) {
        // ASSETS && RVN
        if (from.unspents.length < limit) {
          // we should be able to do it all in one transaction
          final Tuple2<wallet_utils.Transaction, SendEstimate> txEstimate =
              await services.transaction.make.transactionSweepAll(
            destinationAddress,
            SendEstimate(from.coinValue, memo: memo),
            wallet: from,
            securities: assetBalances.map((Balance e) => e.security).toSet(),
            feeRate: wallet_utils.FeeRates.standard,
          );
          streams.spend.send.add(TransactionNote(
            txHex: txEstimate.item1.toHex(),
            successMsg: msg ?? 'Successfully Swept',
            note: note,
          ));
          usedUTXOs.addAll(txEstimate.item2.utxos);
          return usedUTXOs;
        } else {
          usedUTXOs.addAll(await sweep(
            from: from,
            toWalletId: toWalletId,
            currency: false,
            assets: true,
            memo: memo,
            note: note,
            msg: '',
            usedUTXOs: usedUTXOs,
            incremental: true,
          ));
          usedUTXOs.addAll(await sweep(
            from: from,
            toWalletId: toWalletId,
            currency: true,
            assets: false,
            memo: memo,
            note: note,
            msg: msg ?? 'Successfully Swept',
            usedUTXOs: usedUTXOs,
            incremental: true,
          ));
          return usedUTXOs;
        }
      } else {
        // JUST ASSETS
        if (from.unspents
                    .where((Unspent e) => !pros.securities.contains(e.security))
                    .length <
                limit &&
            usedUTXOs.isEmpty &&
            !incremental) {
          for (final Balance balance in assetBalances) {
            final Tuple2<wallet_utils.Transaction, SendEstimate> txEstimate =
                await services.transaction.make.transaction(
              destinationAddress,
              SendEstimate(balance.value,
                  security: balance.security, memo: memo),
              wallet: from,
              feeRate: wallet_utils.FeeRates.standard,
            );
            streams.spend.send.add(TransactionNote(
              txHex: txEstimate.item1.toHex(),
              successMsg: msg ?? 'Successfully Swept',
              note: note,
            ));
            usedUTXOs.addAll(txEstimate.item2.utxos);
          }
          return usedUTXOs;
        } else {
          // get all utxos
          final Map<Security, List<Vout>> assetUtxosBySecurity =
              <Security, List<Vout>>{};
          final Set<Security> securities =
              assetBalances.map((Balance e) => e.security).toSet();
          for (final Security security in securities) {
            assetUtxosBySecurity[security] =
                (await services.balance.collectUTXOs(
              walletId: from.id,
              amount:
                  pros.balances.primaryIndex.getOne(from.id, security)!.value,
              security: security,
            ))
                    .where((Vout e) => !usedUTXOs!.contains(e))
                    .toList();
          }
          // batch by limit and make transaction
          Map<Security, List<Vout>> utxosBySecurity = <Security, List<Vout>>{};
          for (final Security key in assetUtxosBySecurity.keys) {
            utxosBySecurity[key] = <Vout>[];
            int i = 0;
            for (final Vout value in assetUtxosBySecurity[key]!) {
              utxosBySecurity[key]!.add(value);
              i++;
              if (i == limit) {
                final Tuple2<wallet_utils.Transaction, SendEstimate>
                    txEstimate = await services.transaction.make
                        .transactionSweepAssetIncrementally(
                  destinationAddress,
                  SendEstimate(0, memo: memo), // essentially ignored
                  utxosBySecurity: utxosBySecurity,
                  wallet: from,
                  feeRate: wallet_utils.FeeRates.standard,
                );
                streams.spend.send.add(TransactionNote(
                  txHex: txEstimate.item1.toHex(),
                  successMsg: '',
                  note: note,
                ));
                usedUTXOs.addAll(txEstimate.item2.utxos);
                await Future<void>.delayed(const Duration(seconds: 10));
                utxosBySecurity = <Security, List<Vout>>{};
                utxosBySecurity[key] = <Vout>[];
                i = 0;
              }
            }
          }
          if (utxosBySecurity.isNotEmpty) {
            final Tuple2<wallet_utils.Transaction, SendEstimate> txEstimate =
                await services.transaction.make
                    .transactionSweepAssetIncrementally(
              destinationAddress,
              SendEstimate(0, memo: memo), // essentially ignored
              utxosBySecurity: utxosBySecurity,
              wallet: from,
              feeRate: wallet_utils.FeeRates.standard,
            );
            streams.spend.send.add(TransactionNote(
              txHex: txEstimate.item1.toHex(),
              successMsg: msg ?? 'Successfully Swept',
              note: note,
            ));
            usedUTXOs.addAll(txEstimate.item2.utxos);
            await Future<void>.delayed(const Duration(seconds: 10));
          }
          return usedUTXOs;
        }
      }
    } else {
      // JUST RVN
      if (from.unspents
                  .where((Unspent e) => !pros.securities.contains(e.security))
                  .length <
              limit &&
          usedUTXOs.isEmpty &&
          !incremental) {
        final Tuple2<wallet_utils.Transaction, SendEstimate> txEstimate =
            await services.transaction.make.transactionSendAllRVN(
          destinationAddress,
          SendEstimate(from.coinValue, memo: memo),
          wallet: from,
          feeRate: wallet_utils.FeeRates.standard,
        );
        streams.spend.send.add(TransactionNote(
          txHex: txEstimate.item1.toHex(),
          successMsg: msg ?? 'Successfully Swept',
          note: note,
        ));
        await Future<void>.delayed(const Duration(seconds: 10));
        usedUTXOs.addAll(txEstimate.item2.utxos);
        return usedUTXOs;
      } else {
        // get all utxos
        final List<Vout> cryptoUtxos = (await services.balance
                .collectUTXOs(walletId: from.id, amount: from.coinValue))
            .where((Vout e) => !usedUTXOs!.contains(e))
            .toList();
        // batch by limit and make transaction
        List<Vout> utxos = <Vout>[];
        int i = 0;
        int total = 0;
        for (final Vout utxo in cryptoUtxos) {
          total = total + utxo.coinValue;
          utxos.add(utxo);
          i++;
          if (i == limit) {
            final Tuple2<wallet_utils.Transaction, SendEstimate> txEstimate =
                await services.transaction.make
                    .transactionSendAllRVNIncrementally(
              destinationAddress,
              SendEstimate(total, memo: memo),
              utxosCurrency: utxos,
              wallet: from,
              feeRate: wallet_utils.FeeRates.standard,
            );
            streams.spend.send.add(TransactionNote(
              txHex: txEstimate.item1.toHex(),
              successMsg: '',
              note: note,
            ));
            await Future<void>.delayed(const Duration(seconds: 10));
            usedUTXOs.addAll(txEstimate.item2.utxos);
            utxos = <Vout>[];
            i = 0;
            total = 0;
          }
        }
        if (utxos.isNotEmpty) {
          final Tuple2<wallet_utils.Transaction, SendEstimate> txEstimate =
              await services.transaction.make
                  .transactionSendAllRVNIncrementally(
            destinationAddress,
            SendEstimate(total, memo: memo), // essentially ignored
            utxosCurrency: utxos,
            wallet: from,
            feeRate: wallet_utils.FeeRates.standard,
          );
          streams.spend.send.add(TransactionNote(
            txHex: txEstimate.item1.toHex(),
            successMsg: msg ?? 'Successfully Swept',
            note: note,
          ));
          usedUTXOs.addAll(txEstimate.item2.utxos);
        }
        return usedUTXOs;
      }
    }
  }

  /// make and execute one or more transactions using all UTXOs
  /// for now sweeping is not done in one transaction, its as many transactions
  /// as needed, segmented by assets and maximum number of utxos. in other words
  /// there will be at least one transaction per security. why? because that's
  /// how we wrote the transaction maker - one asset at a time. making sweep
  /// more correct means redoing that entire thing.
  ///
  /// this one doesn't really work because it sends the assets, then sends
  /// change back to self, but it tries to send the rvn right away before it
  /// gets the unspents of the change.
  Future<bool> sweepEZ({
    required Wallet from,
    required String toWalletId,
    required bool currency,
    required bool assets,
  }) async {
    final String destinationAddress = services.wallet.getEmptyAddress(
      pros.wallets.primaryIndex.getOne(toWalletId)!,
      NodeExposure.external,
    );
    final List<Balance> assetBalances =
        from.balances.where((Balance b) => b.security.symbol != 'RVN').toList();

    // if we have assets, send them, and send all the rvn
    // if we don't have assets or don't want to send them, just sendallRVN

    if (from.unspents.isEmpty || from.coinValue == 0) {
      // unable to perform any transactions
      return false;
    }

    int fees = 0;
    if (assets &&
        assetBalances.isNotEmpty &&
        assetBalances.fold(0, (int agg, Balance e) => e.value + agg) > 0) {
      for (final Balance balance in assetBalances) {
        final Tuple2<wallet_utils.Transaction, SendEstimate> txEstimate =
            await services.transaction.make.transaction(
          destinationAddress,
          SendEstimate(balance.value, security: balance.security),
          wallet: from,
          feeRate: wallet_utils.FeeRates.standard,
        );
        streams.spend.send.add(TransactionNote(
          txHex: txEstimate.item1.toHex(),
          successMsg: 'Successfully Swept',
        ));
        fees += txEstimate.item2.fees;
      }
    }
    if (currency) {
      final Balance balance =
          from.balances.where((Balance e) => e.security.symbol == 'RVN').first;
      final Tuple2<wallet_utils.Transaction, SendEstimate> txEstimate =
          await services.transaction.make.transactionSendAllRVN(
        destinationAddress,
        SendEstimate(balance.value - fees),
        wallet: from,
        feeRate: wallet_utils.FeeRates.standard,
      );
      streams.spend.send.add(TransactionNote(
        txHex: txEstimate.item1.toHex(),
        successMsg: 'Successfully Swept',
      ));
    }
    return true;
    //if (sendRequest != null) {
    //  print('SEND REQUEST $sendRequest');
    //  Tuple2<ravencoin.Transaction, SendEstimate> tuple;
    //  try {
    //    tuple = await services.transaction.make.transactionBy(sendRequest);
    //    ravencoin.Transaction tx = tuple.item1;
    //    SendEstimate estimate = tuple.item2;
    //
    //    /// extra safety - fee guard clause
    //    if (estimate.fees > 2 * wallet_utils.satsPerCoin) {
    //      throw Exception(
    //          'FEE IS TOO LARGE! NO FEE SHOULD EVER BE THIS BIG!');
    //    }
    //
    //    streams.spend.made.add(TransactionNote(
    //      txHex: tx.toHex(),
    //      note: sendRequest.note,
    //    ));
    //    streams.spend.estimate.add(estimate);
    //    streams.spend.make.add(null);
  }
}

class TransactionRecord {
  TransactionRecord({
    required this.transaction,
    required this.security,
    required this.formattedDatetime,
    required this.type,
    this.height,
    this.fee = 0,
    this.totalIn = 0,
    this.totalOut = 0,
    this.valueOverride,
  });
  Transaction transaction;
  Security security;
  String formattedDatetime;
  int totalIn;
  int totalOut;
  int? height;
  TransactionViewType type;
  int fee;
  int? valueOverride;
  bool pulling = false;

  int get value => valueOverride ?? (totalIn - totalOut).abs();
  bool get out => (totalIn - totalOut) >= 0;
  String get formattedValue => security.symbol == 'RVN'
      ? NumberFormat('RVN #,##0.00000000', 'en_US').format(value)
      : NumberFormat(
              '${security.symbol} #,##0.${'0' * (security.asset?.divisibility ?? 0)}',
              'en_US')
          .format(value);

  @override
  String toString() => 'TransactionRecord('
      'transaction: $transaction, '
      'security: $security, '
      'totalIn: $totalIn, '
      'totalOut: $totalOut, '
      'formattedDatetime: $formattedDatetime, '
      'height: $height)';

  String get typeToString {
    switch (type) {
      case TransactionViewType.fee:
        return 'Transaction Fee';
      case TransactionViewType.create:
        return 'Asset Creation';
      case TransactionViewType.burn:
        return 'Burn';
      case TransactionViewType.reissue:
        return 'Reissue';
      case TransactionViewType.tag:
        return 'Tag';
      case TransactionViewType.self:
        return 'Sent to Self';
      case TransactionViewType.incoming:
        return 'Received';
      case TransactionViewType.outgoing:
        return 'Sent';
      case TransactionViewType.claim:
        return 'Claim';
      default:
        return 'Transaction';
    }
  }

  bool get toSelf => type == TransactionViewType.self;
  bool get isNormal => <TransactionViewType>[
        TransactionViewType.incoming,
        TransactionViewType.outgoing,
      ].contains(type);

  Future<void> getVouts() async {
    if (!pulling) {
      pulling = true;
      final Set<String> voutTransactionIds = <String>{};
      for (final Vin vin in transaction.vins) {
        final Vout? vinVout = vin.vout;
        if (vinVout == null) {
          voutTransactionIds.add(vin.voutTransactionId);
        }
      }
      //services.download.history.getAndSaveTransactions(voutTransactionIds);
      await services.download.history.getTransactions(
        services.download.history
            .filterOutPreviouslyDownloaded(voutTransactionIds),
        saveVin: false,
      );
    }
  }
}

class SecurityTotal {
  SecurityTotal({required this.security, required this.value});
  final Security security;
  final int value;

  SecurityTotal operator +(SecurityTotal other) => security == other.security
      ? SecurityTotal(security: security, value: value + other.value)
      : throw BalanceMismatch("Securities don't match - can't combine");

  SecurityTotal operator -(SecurityTotal other) => security == other.security
      ? SecurityTotal(security: security, value: value - other.value)
      : throw BalanceMismatch("Securities don't match - can't combine");
}
