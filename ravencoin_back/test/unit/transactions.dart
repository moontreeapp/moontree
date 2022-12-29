import 'dart:typed_data';
import 'package:wallet_utils/wallet_utils.dart' as wallet_utils;
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/transaction/transaction.dart';
import 'package:test/test.dart';
import 'package:rxdart/subjects.dart';
import 'package:moontree_utils/moontree_utils.dart';

extension TransactionViewMethods on TransactionViewSpoof {
  String? get note => pros.notes.primaryIndex.getOne(readableHash)?.note;
  String get readableHash => hash.toHex();

  Security? get security => symbol == null
      ? pros.securities.currentCoin
      : pros.securities.byKey
          .getOne(symbol, pros.settings.chain, pros.settings.net);

  Chaindata get chaindata => (String chainNet) {
        switch (chainNet) {
          case 'ravencoin_mainnet':
            return ravencoinMainnetChaindata;
          case 'ravencoin_testnet':
            return ravencoinTestnetChaindata;
          case 'evrmore_mainnet':
            return evrmoreMainnetChaindata;
          case 'evrmore_testnet':
            return evrmoreTestnetChaindata;
          default:
            return ravencoinMainnetChaindata;
        }
      }(chain);

  /// true is outgoing false is incoming
  bool get outgoing => (iReceived - iProvided) <= 0;

  double get amount => iValue.asCoin;

  int get iValue => (iReceived - iProvided).abs();

  bool get sentToSelf => iProvided == iReceived + txFee;

  bool get isNormal => false;

  /// always positive
  int get txFee => totalIn - (iReceived + otherReceived + totalBurn);

  /// always positive
  bool get iPaidTxFee => otherProvided == 0;

  int get totalIn => (iProvided + otherProvided);
  int get totalOut => (iReceived + otherReceived) + txFee + totalBurn;
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

  String typeToString(TransactionViewType transactionRecordType) {
    switch (transactionRecordType) {
      case TransactionViewType.self:
        return 'Sent to Self';
      case TransactionViewType.incoming:
        return 'Received';
      case TransactionViewType.outgoing:
        return 'Sent';
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
      case TransactionViewType.claim:
        return 'Claim';
      case TransactionViewType.createAsset:
        return 'Create';
      case TransactionViewType.createSubAsset:
        return 'Create';
      case TransactionViewType.createNFT:
        return 'Create';
      case TransactionViewType.createMessage:
        return 'Create';
      case TransactionViewType.createQualifier:
        return 'Create';
      case TransactionViewType.createSubQualifier:
        return 'Create';
      case TransactionViewType.createRestricted:
        return 'Create';
    }
  }

  /// asset creation, reissue, send, etc.
  /// did we sent to burn address? only sent to self?
  TransactionViewType get type {
    // For a more comprehensive check, we should make sure new assets vouts
    // actually exist. also how would this work for assets?
    TransactionViewType? burned() {
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
      if (issueSubQualifierBurned == chaindata.burnAmounts.issueSubQualifier) {
        return TransactionViewType.createSubQualifier;
      }
      if (issueRestrictedBurned == chaindata.burnAmounts.issueRestricted) {
        return TransactionViewType.createRestricted;
      }
      if (addTagBurned == chaindata.burnAmounts.addTag) {
        return TransactionViewType.tag;
      }
      if (totalBurn > 0) {
        return TransactionViewType.burn;
      }
      return null;
    }

    final regular = sentToSelf
        ? TransactionViewType.self
        : iValue > 0
            ? TransactionViewType.incoming
            : TransactionViewType.outgoing;
    final burn = burned();
    return burn ?? regular;
  }

  String get paddedType {
    final TransactionViewType t = type;
    if (t == TransactionViewType.incoming ||
        t == TransactionViewType.outgoing) {
      return '';
    }
    return '| ${typeToString(t)}';
  }

  int get fee => iPaidTxFee ? txFee : 0;
  int get relativeValue =>
      type == TransactionViewType.self ? iProvided : (iValue - fee);
}

List<TransactionViewSpoof> getTransactionViewSpoof() {
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
