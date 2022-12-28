import 'dart:typed_data';
import 'package:wallet_utils/wallet_utils.dart' as wallet_utils;
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/transaction/transaction.dart';
import 'package:test/test.dart';
import 'package:rxdart/subjects.dart';
import 'package:moontree_utils/moontree_utils.dart';

List<TransactionView> getTransactionViewSpoof() {
  final views = <TransactionView>[
    TransactionView(
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
    TransactionView(
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
    TransactionView(
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
    TransactionView(
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
    TransactionView(
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

void main() async {
  test('TransactionView has correct values', () async {
    final views = getTransactionViewSpoof();
    for (final v in views) {
      expect(v.txFee, 100000000);
    }
    expect(views[0].iValue, 700000000);
    expect(views[1].iValue, 800000000);
    expect(views[2].iValue, 2500000000);
    expect(views[3].iValue, 100000000);
    expect(views[4].iValue, 50100000000);
    expect(views[0].type, TransactionViewType.outgoing);
    expect(views[1].type, TransactionViewType.outgoing);
    expect(views[2].type, TransactionViewType.incoming);
    expect(views[3].type, TransactionViewType.self);
    expect(views[4].type, TransactionViewType.createAsset);
  });
}
