import 'package:intl/intl.dart';
import 'package:utils/extensions/map.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/spend.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' show FeeRates;

import 'maker.dart';

class TransactionService {
  final TransactionMaker make = TransactionMaker();

  List<Vout> walletUnspents(Wallet wallet, {Security? security}) =>
      VoutProclaim.whereUnspent(
              given: wallet.vouts,
              security: security ?? pros.securities.currentCrypto,
              includeMempool: false)
          .toList();

  Transaction? getTransactionFrom({Transaction? transaction, String? hash}) {
    transaction ??
        hash ??
        (() => throw OneOfMultipleMissing(
            'transaction or hash required to identify record.'))();
    return transaction ?? pros.transactions.primaryIndex.getOne(hash ?? '');
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
    var givenAddresses =
        wallet.addresses.map((address) => address.address).toSet();
    var transactionRecords = <TransactionRecord>[];
    final currentCrypto = pros.securities.currentCrypto;

    final net = networkOf(pros.settings.chain, pros.settings.net);
    final specialTag = {net.burnAddresses.addTag: net.burnAmounts.addTag};
    final specialReissue = {net.burnAddresses.reissue: net.burnAmounts.reissue};
    final specialCreate = {
      net.burnAddresses.issueMain: net.burnAmounts.issueMain,
      net.burnAddresses.issueMessage: net.burnAmounts.issueMessage,
      net.burnAddresses.issueQualifier: net.burnAmounts.issueQualifier,
      net.burnAddresses.issueRestricted: net.burnAmounts.issueRestricted,
      net.burnAddresses.issueSub: net.burnAmounts.issueSub,
      net.burnAddresses.issueSubQualifier: net.burnAmounts.issueSub,
      net.burnAddresses.issueSubQualifier: net.burnAmounts.issueSubQualifier,
      net.burnAddresses.issueUnique: net.burnAmounts.issueUnique
    };
    for (var transaction in pros.transactions.chronological) {
      final securitiesInvolved = ((transaction.vins
                  .where((vin) =>
                      givenAddresses.contains(vin.vout?.toAddress) &&
                      vin.vout?.security != null)
                  .map((vin) => vin.vout?.security)
                  .toList()) +
              (transaction.vouts
                  .where((vout) =>
                      givenAddresses.contains(vout.toAddress) &&
                      vout.security != null)
                  .map((vout) => vout.security)
                  .toList()))
          .toSet();
      for (var security in securitiesInvolved) {
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
          final outgoingAddrs = <String, int>{};

          if (security == currentCrypto) {
            var selfIn = 0;
            var othersIn = 0;
            var selfOut = 0;
            var othersOut = 0;

            // self out can be broken into two categories based on the address it was sent to
            var outIntentional = 0;
            // ignore: unused_local_variable
            var outChange = 0; // actually used.
            var feeFlag = false;

            var totalInRVN = 0;
            var totalOutRVN = 0;
            var ioType;
            // Nothing too special about incoming...
            for (final vin in transaction.vins) {
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
              var vinVout = vin.vout;

              /// we have another issue when it comes to the claim process:
              /// we don't download the genesis block of the EVR chain so we do
              /// not have the vout that those claim transactions point to. so
              /// we have a special case for that here.

              if (vin.voutTransactionId ==
                  'c191c775b10d2af1fcccb4121095b2a018f1bee84fa5efb568fcddd383969262') {
                //print(pros.unspents.records);
                //print(vin.transactionId);
                //var value = pros.unspents.records
                //    .where((u) => u.transactionId == vin.transactionId)
                //    .fold(0,
                //        (int? running, Unspent u) => u.value + (running ?? 0));
                //selfIn += value;
                //totalInRVN += value;
                //feeFlag = true;
                var utxos = pros.unspents.records
                    .where((u) => u.transactionId == vin.transactionId);
                Unspent utxo;
                if (utxos.isNotEmpty) {
                  utxo = utxos.first;
                  vinVout = Vout.fromUnspent(utxo,
                      //simulate fee since it's hard to determin for claims
                      rvnValue: utxo.value - 211200,
                      toAddress: //utxo.address?.address ??
                          pros.addresses.byScripthash
                              .getOne(utxo.scripthash)
                              ?.address);
                }
                ioType ??= TransactionRecordType.claim;
              }
              if (vinVout == null) {
                /// unable to await so set flag
                //services.download.history
                //    .getAndSaveTransactions({vin.voutTransactionId});
                feeFlag = true;
              }
              if ((vinVout?.security ?? currentCrypto) == currentCrypto) {
                if (givenAddresses.contains(vinVout?.toAddress)) {
                  selfIn += vinVout?.rvnValue ?? 0;
                } else {
                  othersIn += vinVout?.rvnValue ?? 0;
                }
                totalInRVN += vinVout?.rvnValue ?? 0;
              }
            }

            for (final vout in transaction.vouts) {
              if (vout.security == currentCrypto) {
                totalOutRVN += vout.rvnValue;
                if (givenAddresses.contains(vout.toAddress)) {
                  selfOut += vout.rvnValue;
                  if (wallet.internalAddresses
                      .map((Address a) => a.address)
                      .contains(vout.toAddress)) {
                    outChange += vout.rvnValue;
                  } else {
                    outIntentional += vout.rvnValue;
                  }
                } else {
                  othersOut += vout.rvnValue;
                  if (specialCreate.containsKey(vout.toAddress) ||
                      specialReissue.containsKey(vout.toAddress) ||
                      specialTag.containsKey(vout.toAddress) ||
                      vout.toAddress == net.burnAddresses.burn) {
                    final current = outgoingAddrs[vout.toAddress!] ?? 0;
                    outgoingAddrs[vout.toAddress!] = current + vout.rvnValue;
                  }
                }
              }
            }

            final fee = (selfIn + othersIn) - (selfOut + othersOut) ==
                    (selfIn + othersIn)
                ? totalInRVN - totalOutRVN
                : (selfIn + othersIn) - (selfOut + othersOut);

            // Known burn addr for tagging
            // This goes first as tags can also be in creations

            // TODO: Better verification; see if actual valid asset vouts exist

            final tagIntersection = outgoingAddrs.keys
                .toSet()
                .intersection(specialTag.keys.toSet());
            if (tagIntersection.isNotEmpty) {
              for (final address in tagIntersection) {
                if (outgoingAddrs[address] == specialTag[address]) {
                  ioType = TransactionRecordType.tag;
                }
              }
              // If not a tag, effectively a burn
              ioType ??= TransactionRecordType.burn;
            }

            final reissueIntersection = outgoingAddrs.keys
                .toSet()
                .intersection(specialReissue.keys.toSet());
            if (reissueIntersection.isNotEmpty) {
              for (final address in reissueIntersection) {
                if (outgoingAddrs[address] == specialReissue[address]) {
                  ioType = TransactionRecordType.reissue;
                }
              }
              // If not a tag, effectively a burn
              ioType ??= TransactionRecordType.burn;
            }

            final createIntersection = outgoingAddrs.keys
                .toSet()
                .intersection(specialCreate.keys.toSet());
            // Known burn addr for creation
            if (createIntersection.isNotEmpty) {
              for (final address in createIntersection) {
                if (outgoingAddrs[address] == specialCreate[address]) {
                  ioType = TransactionRecordType.create;
                }
              }
              // If not a tag, effectively a burns
              ioType ??= TransactionRecordType.burn;
            }

            // Only call it "sent to self" if no RVN is coming from anywhere else
            //if (othersIn == 0 && othersOut == 0 && selfIn > 0 && selfOut > 0) {
            // if no input from others, and everything spend is everything received
            // then it's sent to self, unless we're looking at ravencoin, in that case
            // maybe this was just a fee to send an asset, in that case, its just a
            // regular out transaction...
            if ((transaction.vouts.map((e) => !e.isAsset).every((e) => e))) {
              if (othersIn == 0 && othersOut == 0 && selfIn == selfOut + fee) {
                if (ioType != TransactionRecordType.claim) {
                  ioType = TransactionRecordType.self;
                }
              }
            } else {
              ioType ??= TransactionRecordType.fee;
            }
            if (selfIn > 0 &&
                outgoingAddrs.containsKey(net.burnAddresses.burn)) {
              ioType = TransactionRecordType.burn;
            }
            // Defaults
            ioType ??= selfIn > selfOut
                ? TransactionRecordType.outgoing
                : TransactionRecordType.incoming;

            //print('s $selfIn $selfOut o $othersIn $othersOut');
            transactionRecords.add(TransactionRecord(
              transaction: transaction,
              security: security!,
              totalIn: selfIn,
              totalOut: selfOut,
              valueOverride: [
                TransactionRecordType.self,
                TransactionRecordType.claim
              ].contains(ioType)
                  ? outIntentional
                  : null,
              height: transaction.height,
              type: ioType,
              fee: feeFlag ? 0 : fee,
              formattedDatetime: transaction.formattedDatetime,
            ));
          } else {
            var selfIn = 0;
            var selfInRVN = 0;
            var othersIn = 0;
            var othersInRVN = 0;

            var selfOut = 0;
            var selfOutRVN = 0;
            var othersOut = 0;
            var othersOutRVN = 0;
            // self out can be broken into two categories based on the address it was sent to
            var outIntentional = 0;
            // ignore: unused_local_variable
            var outChange = 0; // used
            var feeFlag = false;

            // Nothing too special about incoming...
            for (final vin in transaction.vins) {
              var vinVout = vin.vout;
              if (vinVout == null) {
                /// unable to await so set flag
                //services.download.history
                //    .getAndSaveTransactions({vin.voutTransactionId});
                feeFlag = true;
              }
              vinVout = vin.vout;
              if (vinVout?.security == currentCrypto) {
                if (givenAddresses.contains(vinVout?.toAddress)) {
                  selfInRVN += vinVout?.rvnValue ?? 0;
                } else {
                  othersInRVN += vinVout?.rvnValue ?? 0;
                }
              } else if (vinVout?.security == security) {
                if (givenAddresses.contains(vinVout?.toAddress)) {
                  selfIn += vinVout?.assetValue ?? 0;
                } else {
                  othersIn += vinVout?.assetValue ?? 0;
                }
              }
            }

            for (final vout in transaction.vouts) {
              if (vout.security == currentCrypto) {
                if (givenAddresses.contains(vout.toAddress)) {
                  selfOutRVN += vout.rvnValue;
                } else {
                  othersOutRVN += vout.rvnValue;
                  if (specialCreate.containsKey(vout.toAddress) ||
                      specialReissue.containsKey(vout.toAddress) ||
                      specialTag.containsKey(vout.toAddress) ||
                      vout.toAddress == net.burnAddresses.burn) {
                    final current = outgoingAddrs[vout.toAddress!] ?? 0;
                    outgoingAddrs[vout.toAddress!] = current + vout.rvnValue;
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

            var ioType;

            // Known burn addr for tagging
            // This goes first as tags can also be in creations

            // TODO: Better verification; see if actual valid asset vouts exist

            final tagIntersection = outgoingAddrs.keys
                .toSet()
                .intersection(specialTag.keys.toSet());
            if (tagIntersection.isNotEmpty) {
              for (final address in tagIntersection) {
                if (outgoingAddrs[address] == specialTag[address]) {
                  ioType = TransactionRecordType.tag;
                }
              }
              // If not a tag, effectively a burn
              ioType ??= TransactionRecordType.burn;
            }

            final reissueIntersection = outgoingAddrs.keys
                .toSet()
                .intersection(specialReissue.keys.toSet());
            if (reissueIntersection.isNotEmpty) {
              for (final address in reissueIntersection) {
                if (outgoingAddrs[address] == specialReissue[address]) {
                  ioType = TransactionRecordType.reissue;
                }
              }
              // If not a tag, effectively a burn
              ioType ??= TransactionRecordType.burn;
            }

            final createIntersection = outgoingAddrs.keys
                .toSet()
                .intersection(specialCreate.keys.toSet());
            // Known burn addr for creation
            if (createIntersection.isNotEmpty) {
              for (final address in createIntersection) {
                if (outgoingAddrs[address] == specialCreate[address]) {
                  ioType = TransactionRecordType.create;
                }
              }
              // If not a tag, effectively a burns
              ioType ??= TransactionRecordType.burn;
            }

            // Only call it "sent to self" if no RVN is coming from anywhere else
            if (othersIn == 0 && othersOut == 0 && selfIn == selfOut) {
              ioType = TransactionRecordType.self;
            }
            if (selfIn > 0 &&
                outgoingAddrs.containsKey(net.burnAddresses.burn)) {
              ioType = TransactionRecordType.burn;
            }
            // Defaults
            ioType ??= selfIn > selfOut
                ? TransactionRecordType.outgoing
                : TransactionRecordType.incoming;

            transactionRecords.add(TransactionRecord(
              transaction: transaction,
              security: security!,
              totalIn: selfIn,
              totalOut: selfOut,
              valueOverride: [
                TransactionRecordType.self,
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
    var ret = <TransactionRecord>[];
    var actual = <TransactionRecord>[];
    for (var txRecord in transactionRecords) {
      if (txRecord.formattedDatetime == 'In Transit') {
        ret.add(txRecord);
      } else {
        actual.add(txRecord);
      }
    }
    ret.addAll(actual);
    return ret;
  }

  /// CLAIM FEATURE
  Future<void> claim({
    required Wallet from,
    required String toWalletId,
    String? note,
    String? memo,
    String? msg,
  }) async {
    final destinationAddress = services.wallet.getEmptyAddress(
      pros.wallets.primaryIndex.getOne(toWalletId)!,
      NodeExposure.external,
    );
    final utxos = streams.claim.unclaimed.value.getOr(from.id, <Vout>{});
    final claimAmount = utxos
        .map((e) => e.rvnValue)
        .reduce((value, element) => value + element);

    var txEstimate = await services.transaction.make.claimAllEVR(
      destinationAddress,
      SendEstimate(claimAmount, memo: memo, utxos: utxos.toList()),
      wallet: from,
      feeRate: FeeRates.standard,
    );
    streams.spend.send.add(TransactionNote(
      txHex: txEstimate.item1.toHex(),
      successMsg: msg ?? 'Successfully Claimed',
      note: note,
    ));
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
    usedUTXOs = usedUTXOs ?? {};
    final destinationAddress = services.wallet.getEmptyAddress(
      pros.wallets.primaryIndex.getOne(toWalletId)!,
      NodeExposure.external,
    );
    final assetBalances = from.balances
        .where((b) => !pros.securities.cryptos.contains(b.security))
        .toList();

    if (from.unspents.isEmpty || from.RVNValue == 0) {
      // unable to perform any transactions
      return usedUTXOs;
    }

    if (assets &&
        assetBalances.isNotEmpty &&
        assetBalances.fold(0, (int agg, e) => e.value + agg) > 0) {
      if (currency) {
        // ASSETS && RVN
        if (from.unspents.length < limit) {
          // we should be able to do it all in one transaction
          var txEstimate = await services.transaction.make.transactionSweepAll(
            destinationAddress,
            SendEstimate(from.RVNValue, memo: memo),
            wallet: from,
            securities: assetBalances.map((e) => e.security).toSet(),
            feeRate: FeeRates.standard,
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
                    .where((e) => !pros.securities.contains(e.security))
                    .length <
                limit &&
            usedUTXOs.isEmpty &&
            !incremental) {
          for (var balance in assetBalances) {
            var txEstimate = await services.transaction.make.transaction(
              destinationAddress,
              SendEstimate(balance.value,
                  security: balance.security, memo: memo),
              wallet: from,
              feeRate: FeeRates.standard,
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
          var assetUtxosBySecurity = <Security, List<Vout>>{};
          final securities = assetBalances.map((e) => e.security).toSet();
          for (var security in securities) {
            assetUtxosBySecurity[security] =
                (await services.balance.collectUTXOs(
              walletId: from.id,
              amount:
                  pros.balances.primaryIndex.getOne(from.id, security)!.value,
              security: security,
            ))
                    .where((e) => !usedUTXOs!.contains(e))
                    .toList();
          }
          // batch by limit and make transaction
          var utxosBySecurity = <Security, List<Vout>>{};
          for (var key in assetUtxosBySecurity.keys) {
            utxosBySecurity[key] = [];
            var i = 0;
            for (var value in assetUtxosBySecurity[key]!) {
              utxosBySecurity[key]!.add(value);
              i++;
              if (i == limit) {
                var txEstimate = await services.transaction.make
                    .transactionSweepAssetIncrementally(
                  destinationAddress,
                  SendEstimate(0,
                      security: null, memo: memo), // essentially ignored
                  utxosBySecurity: utxosBySecurity,
                  wallet: from,
                  feeRate: FeeRates.standard,
                );
                streams.spend.send.add(TransactionNote(
                  txHex: txEstimate.item1.toHex(),
                  successMsg: '',
                  note: note,
                ));
                usedUTXOs.addAll(txEstimate.item2.utxos);
                await Future.delayed(Duration(seconds: 10));
                utxosBySecurity = <Security, List<Vout>>{};
                utxosBySecurity[key] = [];
                i = 0;
              }
            }
          }
          if (utxosBySecurity.isNotEmpty) {
            var txEstimate = await services.transaction.make
                .transactionSweepAssetIncrementally(
              destinationAddress,
              SendEstimate(0,
                  security: null, memo: memo), // essentially ignored
              utxosBySecurity: utxosBySecurity,
              wallet: from,
              feeRate: FeeRates.standard,
            );
            streams.spend.send.add(TransactionNote(
              txHex: txEstimate.item1.toHex(),
              successMsg: msg ?? 'Successfully Swept',
              note: note,
            ));
            usedUTXOs.addAll(txEstimate.item2.utxos);
            await Future.delayed(Duration(seconds: 10));
          }
          return usedUTXOs;
        }
      }
    } else {
      // JUST RVN
      if (from.unspents
                  .where((e) => !pros.securities.contains(e.security))
                  .length <
              limit &&
          usedUTXOs.isEmpty &&
          !incremental) {
        var txEstimate = await services.transaction.make.transactionSendAllRVN(
          destinationAddress,
          SendEstimate(from.RVNValue, memo: memo),
          wallet: from,
          feeRate: FeeRates.standard,
        );
        streams.spend.send.add(TransactionNote(
          txHex: txEstimate.item1.toHex(),
          successMsg: msg ?? 'Successfully Swept',
          note: note,
        ));
        await Future.delayed(Duration(seconds: 10));
        usedUTXOs.addAll(txEstimate.item2.utxos);
        return usedUTXOs;
      } else {
        // get all utxos
        var cryptoUtxos = (await services.balance.collectUTXOs(
                walletId: from.id, amount: from.RVNValue, security: null))
            .where((e) => !usedUTXOs!.contains(e))
            .toList();
        // batch by limit and make transaction
        var utxos = <Vout>[];
        var i = 0;
        var total = 0;
        for (var utxo in cryptoUtxos) {
          total = total + utxo.rvnValue;
          utxos.add(utxo);
          i++;
          if (i == limit) {
            var txEstimate = await services.transaction.make
                .transactionSendAllRVNIncrementally(
              destinationAddress,
              SendEstimate(total, security: null, memo: memo),
              utxosCurrency: utxos,
              wallet: from,
              feeRate: FeeRates.standard,
            );
            streams.spend.send.add(TransactionNote(
              txHex: txEstimate.item1.toHex(),
              successMsg: '',
              note: note,
            ));
            await Future.delayed(Duration(seconds: 10));
            usedUTXOs.addAll(txEstimate.item2.utxos);
            utxos = <Vout>[];
            i = 0;
            total = 0;
          }
        }
        if (utxos.isNotEmpty) {
          var txEstimate = await services.transaction.make
              .transactionSendAllRVNIncrementally(
            destinationAddress,
            SendEstimate(total,
                security: null, memo: memo), // essentially ignored
            utxosCurrency: utxos,
            wallet: from,
            feeRate: FeeRates.standard,
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
    final destinationAddress = services.wallet.getEmptyAddress(
      pros.wallets.primaryIndex.getOne(toWalletId)!,
      NodeExposure.external,
    );
    final assetBalances =
        from.balances.where((b) => b.security.symbol != 'RVN').toList();

    // if we have assets, send them, and send all the rvn
    // if we don't have assets or don't want to send them, just sendallRVN

    if (from.unspents.isEmpty || from.RVNValue == 0) {
      // unable to perform any transactions
      return false;
    }

    var fees = 0;
    if (assets &&
        assetBalances.isNotEmpty &&
        assetBalances.fold(0, (int agg, e) => e.value + agg) > 0) {
      for (var balance in assetBalances) {
        var txEstimate = await services.transaction.make.transaction(
          destinationAddress,
          SendEstimate(balance.value, security: balance.security),
          wallet: from,
          feeRate: FeeRates.standard,
        );
        streams.spend.send.add(TransactionNote(
          txHex: txEstimate.item1.toHex(),
          successMsg: 'Successfully Swept',
        ));
        fees += txEstimate.item2.fees;
      }
    }
    if (currency) {
      final balance =
          from.balances.where((e) => e.security.symbol == 'RVN').first;
      var txEstimate = await services.transaction.make.transactionSendAllRVN(
        destinationAddress,
        SendEstimate(balance.value - fees, security: null),
        wallet: from,
        feeRate: FeeRates.standard,
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
    //    if (estimate.fees > 2 * 100000000) {
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

enum TransactionRecordType {
  incoming,
  outgoing,
  fee,
  self,
  create,
  tag,
  burn,
  reissue,
  claim,
}

class TransactionRecord {
  Transaction transaction;
  Security security;
  String formattedDatetime;
  int totalIn;
  int totalOut;
  int? height;
  TransactionRecordType type;
  int fee;
  int? valueOverride;
  bool pulling = false;

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
      case TransactionRecordType.fee:
        return 'Transaction Fee';
      case TransactionRecordType.create:
        return 'Asset Creation';
      case TransactionRecordType.burn:
        return 'Burn';
      case TransactionRecordType.reissue:
        return 'Reissue';
      case TransactionRecordType.tag:
        return 'Tag';
      case TransactionRecordType.self:
        return 'Sent to Self';
      case TransactionRecordType.incoming:
        return 'Received';
      case TransactionRecordType.outgoing:
        return 'Sent';
      case TransactionRecordType.claim:
        return 'Claim';
    }
  }

  bool get toSelf => type == TransactionRecordType.self;
  bool get isNormal => [
        TransactionRecordType.incoming,
        TransactionRecordType.outgoing,
      ].contains(type);

  void getVouts() async {
    if (!pulling) {
      pulling = true;
      var voutTransactionIds = <String>{};
      for (final vin in transaction.vins) {
        var vinVout = vin.vout;
        if (vinVout == null) {
          voutTransactionIds.add(vin.voutTransactionId);
        }
      }
      //services.download.history.getAndSaveTransactions(voutTransactionIds);
      await services.download.history.getTransactions(
        services.download.history
            .filterOutPreviouslyDownloaded(voutTransactionIds),
        saveVin: false,
        saveVout: true,
      );
    }
  }
}

class SecurityTotal {
  final Security security;
  final int value;

  SecurityTotal({required this.security, required this.value});

  SecurityTotal operator +(SecurityTotal other) => security == other.security
      ? SecurityTotal(security: security, value: value + other.value)
      : throw BalanceMismatch("Securities don't match - can't combine");

  SecurityTotal operator -(SecurityTotal other) => security == other.security
      ? SecurityTotal(security: security, value: value - other.value)
      : throw BalanceMismatch("Securities don't match - can't combine");
}
