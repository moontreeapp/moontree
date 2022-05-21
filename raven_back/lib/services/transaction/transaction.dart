import 'package:intl/intl.dart';
import 'package:raven_back/raven_back.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' as networks;

import 'maker.dart';

class TransactionService {
  final TransactionMaker make = TransactionMaker();

  List<Vout> walletUnspents(Wallet wallet, {Security? security}) =>
      VoutReservoir.whereUnspent(
              given: wallet.vouts,
              security: security ?? res.securities.RVN,
              includeMempool: false)
          .toList();

  Transaction? getTransactionFrom({Transaction? transaction, String? hash}) {
    transaction ??
        hash ??
        (() => throw OneOfMultipleMissing(
            'transaction or hash required to identify record.'))();
    return transaction ?? res.transactions.primaryIndex.getOne(hash ?? '');
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
    final rvn = res.securities.RVN;

    final net = res.settings.mainnet ? networks.mainnet : networks.testnet;
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
    for (var transaction in res.transactions.chronological) {
      print(transaction);
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

          if (security == rvn) {
            var selfIn = 0;
            var othersIn = 0;

            var selfOut = 0;
            var othersOut = 0;

            // Nothing too special about incoming...
            for (final vin in transaction.vins) {
              if ((vin.vout?.security ?? rvn) == rvn) {
                if (givenAddresses.contains(vin.vout?.toAddress)) {
                  selfIn += vin.vout?.rvnValue ?? 0;
                } else {
                  othersIn += vin.vout?.rvnValue ?? 0;
                }
              }
            }

            for (final vout in transaction.vouts) {
              if (vout.security == rvn) {
                if (givenAddresses.contains(vout.toAddress)) {
                  selfOut += vout.rvnValue;
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
                  ioType = TransactionRecordType.TAG;
                }
              }
              // If not a tag, effectively a burn
              ioType ??= TransactionRecordType.BURN;
            }

            final reissueIntersection = outgoingAddrs.keys
                .toSet()
                .intersection(specialReissue.keys.toSet());
            if (reissueIntersection.isNotEmpty) {
              for (final address in reissueIntersection) {
                if (outgoingAddrs[address] == specialReissue[address]) {
                  ioType = TransactionRecordType.REISSUE;
                }
              }
              // If not a tag, effectively a burn
              ioType ??= TransactionRecordType.BURN;
            }

            final createIntersection = outgoingAddrs.keys
                .toSet()
                .intersection(specialCreate.keys.toSet());
            // Known burn addr for creation
            if (createIntersection.isNotEmpty) {
              for (final address in createIntersection) {
                if (outgoingAddrs[address] == specialCreate[address]) {
                  ioType = TransactionRecordType.ASSETCREATION;
                }
              }
              // If not a tag, effectively a burns
              ioType ??= TransactionRecordType.BURN;
            }

            // Only call it "sent to self" if no RVN is coming from anywhere else

            if (othersIn == 0 && othersOut == 0 && selfIn > 0) {
              ioType = TransactionRecordType.SELF;
            }
            if (selfIn > 0 &&
                outgoingAddrs.containsKey(net.burnAddresses.burn)) {
              ioType = TransactionRecordType.BURN;
            }
            // Defaults
            ioType ??= selfIn > selfOut
                ? TransactionRecordType.OUTGOING
                : TransactionRecordType.INCOMING;

            print('s $selfIn $selfOut o $othersIn $othersOut');
            transactionRecords.add(TransactionRecord(
              transaction: transaction,
              security: security!,
              totalIn: selfIn,
              totalOut: selfOut,
              height: transaction.height,
              type: ioType,
              fee: (selfIn + othersIn) - (selfOut + othersOut),
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

            // Nothing too special about incoming...
            for (final vin in transaction.vins) {
              if (vin.vout?.security == rvn) {
                if (givenAddresses.contains(vin.vout?.toAddress)) {
                  selfInRVN += vin.vout?.rvnValue ?? 0;
                } else {
                  othersInRVN += vin.vout?.rvnValue ?? 0;
                }
              } else if (vin.vout?.security == security) {
                if (givenAddresses.contains(vin.vout?.toAddress)) {
                  selfIn += vin.vout?.assetValue ?? 0;
                } else {
                  othersIn += vin.vout?.assetValue ?? 0;
                }
              }
            }

            for (final vout in transaction.vouts) {
              if (vout.security == rvn) {
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
                  ioType = TransactionRecordType.TAG;
                }
              }
              // If not a tag, effectively a burn
              ioType ??= TransactionRecordType.BURN;
            }

            final reissueIntersection = outgoingAddrs.keys
                .toSet()
                .intersection(specialReissue.keys.toSet());
            if (reissueIntersection.isNotEmpty) {
              for (final address in reissueIntersection) {
                if (outgoingAddrs[address] == specialReissue[address]) {
                  ioType = TransactionRecordType.REISSUE;
                }
              }
              // If not a tag, effectively a burn
              ioType ??= TransactionRecordType.BURN;
            }

            final createIntersection = outgoingAddrs.keys
                .toSet()
                .intersection(specialCreate.keys.toSet());
            // Known burn addr for creation
            if (createIntersection.isNotEmpty) {
              for (final address in createIntersection) {
                if (outgoingAddrs[address] == specialCreate[address]) {
                  ioType = TransactionRecordType.ASSETCREATION;
                }
              }
              // If not a tag, effectively a burns
              ioType ??= TransactionRecordType.BURN;
            }

            // Only call it "sent to self" if no RVN is coming from anywhere else
            if (othersIn == 0 && othersOut == 0 && selfIn > 0) {
              ioType = TransactionRecordType.SELF;
            }
            if (selfIn > 0 &&
                outgoingAddrs.containsKey(net.burnAddresses.burn)) {
              ioType = TransactionRecordType.BURN;
            }
            // Defaults
            ioType ??= selfIn > selfOut
                ? TransactionRecordType.OUTGOING
                : TransactionRecordType.INCOMING;

            transactionRecords.add(TransactionRecord(
              transaction: transaction,
              security: security!,
              totalIn: selfIn,
              totalOut: selfOut,
              height: transaction.height,
              type: ioType,
              fee: (selfInRVN + othersInRVN) - (selfOutRVN + othersOutRVN),
              formattedDatetime: transaction.formattedDatetime,
            ));
          }
        }
      }
    }
    var ret = <TransactionRecord>[];
    var actual = <TransactionRecord>[];
    for (var txRecord in transactionRecords) {
      if (txRecord.formattedDatetime == 'in mempool') {
        ret.add(txRecord);
      } else {
        actual.add(txRecord);
      }
    }
    ret.addAll(actual);
    return ret;
  }
}

enum TransactionRecordType {
  INCOMING,
  OUTGOING,
  SELF,
  ASSETCREATION,
  TAG,
  BURN,
  REISSUE,
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

  TransactionRecord({
    required this.transaction,
    required this.security,
    required this.formattedDatetime,
    required this.type,
    this.height,
    this.fee = 0,
    this.totalIn = 0,
    this.totalOut = 0,
  });

  int get value => (totalIn - totalOut).abs();
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
      case TransactionRecordType.ASSETCREATION:
        return 'Asset Creation';
      case TransactionRecordType.BURN:
        return 'Burn';
      case TransactionRecordType.REISSUE:
        return 'Reissue';
      case TransactionRecordType.TAG:
        return 'Tag';
      case TransactionRecordType.SELF:
        return 'Sent To Self';
      case TransactionRecordType.INCOMING:
        return 'Received';
      case TransactionRecordType.OUTGOING:
        return 'Sent';
    }
  }

  bool get toSelf => type == TransactionRecordType.SELF;
  bool get isNormal => [
        TransactionRecordType.SELF,
        TransactionRecordType.INCOMING,
        TransactionRecordType.OUTGOING,
      ].contains(type);
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
