import 'dart:typed_data';
import 'package:client_back/records/types/transaction_view.dart';
import 'package:client_back/server/src/protocol/comm_transaction_view.dart';
import 'package:wallet_utils/wallet_utils.dart' as wallet_utils;
import 'package:client_back/client_back.dart';
import 'package:client_back/services/transaction/transaction.dart';
import 'package:test/test.dart';
import 'package:rxdart/subjects.dart';
import 'package:moontree_utils/moontree_utils.dart';

List<TransactionView> spoofTransactionView() {
  final views = <TransactionView>[
    TransactionView(
        // send transaction
        symbol: null,
        chain: null,
        containsAssets: false,
        consolidation: false,
        hash: ByteData(0),
        datetime: DateTime.now(),
        height: 0,
        fee: 500000,
        vsize: 100,
        iProvided: 27 * wallet_utils.satsPerCoin,
        //otherProvided: 4 *  wallet_utils.satsPerCoin,
        iReceived: 2699500000,
        //otherReceived: 10 *  wallet_utils.satsPerCoin,
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
        symbol: null,
        chain: null,
        containsAssets: false,
        consolidation: false,
        hash: ByteData(0),
        datetime: DateTime.now(),
        height: 0,
        fee: 1 * wallet_utils.satsPerCoin,
        vsize: 100,
        iProvided: 27 * wallet_utils.satsPerCoin,
        //otherProvided: 4 *  wallet_utils.satsPerCoin,
        iReceived: 20 * wallet_utils.satsPerCoin,
        //otherReceived: 10 *  wallet_utils.satsPerCoin,
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
        symbol: null,
        chain: null,
        containsAssets: false,
        consolidation: false,
        hash: ByteData(0),
        datetime: DateTime.now(),
        height: 0,
        //10 decimal package has a problem here. instead of 0.0000001 we get 0.00000001
        fee: 1,
        vsize: 100,
        iProvided: 27000 * wallet_utils.satsPerCoin,
        //otherProvided: 0,
        iReceived: 19000 * wallet_utils.satsPerCoin,
        //otherReceived: 7 *  wallet_utils.satsPerCoin,
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
        symbol: null,
        chain: null,
        containsAssets: false,
        consolidation: false,
        hash: ByteData(0),
        datetime: DateTime.now(),
        height: 0,
        fee: 266000,
        vsize: 100,
        iProvided: 1 * wallet_utils.satsPerCoin,
        //otherProvided: 26 *  wallet_utils.satsPerCoin,
        iReceived: 26 * wallet_utils.satsPerCoin,
        //otherReceived: 0,
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
        symbol: null,
        chain: null,
        containsAssets: false,
        consolidation: false,
        hash: ByteData(0),
        datetime: DateTime.now(),
        height: 0,
        fee: 1,
        vsize: 100,
        iProvided: 27 * wallet_utils.satsPerCoin,
        //otherProvided: 0,
        iReceived: 26 * wallet_utils.satsPerCoin,
        //otherReceived: 0,
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
        symbol: null,
        chain: null,
        containsAssets: false,
        consolidation: false,
        hash: ByteData(1),
        datetime: DateTime.now(),
        height: 1,
        fee: 1,
        vsize: 100,
        iProvided: 600 * wallet_utils.satsPerCoin,
        //otherProvided: 0,
        iReceived: 99 * wallet_utils.satsPerCoin,
        //otherReceived: 0,
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
    final views = spoofTransactionView();
    for (final v in views) {
      expect(v.fee, 100000000);
    }
    // spoof has changed, haven't updated.
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
