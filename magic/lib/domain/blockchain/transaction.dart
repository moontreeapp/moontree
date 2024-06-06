import 'package:magic/domain/server/protocol/comm_transaction_view.dart';
import 'package:moontree_utils/extensions/bytedata.dart';

extension TransactionViewMethods on TransactionView {
  //String? get note => pros.notes.primaryIndex.getOne(readableHash)?.note;
  String get readableHash => hash.toHex();

  //Security? get security => symbol == null
  //    ? pros.securities.currentCoin
  //    : pros.securities.byKey
  //        .getOne(symbol, pros.settings.chain, pros.settings.net);
//
  //Chaindata get chaindata => ChainNet.from(name: chain).chaindata;

  /// true is outgoing false is incoming
  bool get outgoing => (iReceived - iProvided) <= 0;
  bool get isNormal => false;

  double get feeRate => fee / vsize;

  /// always positive
  //bool get iPaidTxFee => otherProvided == 0;
  bool get iPaidFee => iProvided > 0;

  //int get totalIn => (iProvided + otherProvided);
  //int get totalOut => (iReceived + otherReceived) + txFee + totalBurn;

  int get iValue => (iReceived - iProvided).abs();

  //int get iFee => iPaidTxFee ? txFee : 0;
  int get iFee => iPaidFee ? fee : 0;

  /// just the total that went away or came in
  int get totalValue => outgoing ? iProvided : iReceived;
  //int get iValueTotal {
  //  return !isCoin &&
  //          [TransactionViewType.self, TransactionViewType.consolidation]
  //              .contains(type) &&
  //          height > 0
  //      ? iReceived
  //      : iValue;
  //}

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

  //bool get sentToSelf => iProvided == iReceived + (isCoin ? fee : 0);

  /// more than 2 vout of the same asset type went into this transaction
  /// and it was sent to self
  //bool get consolidationToSelf => sentToSelf && consolidation;
//
  //bool get feeOnly => isCoin && (iProvided - iReceived) == fee;
//
  //bool get isCoin => security?.isCoin ?? false;
//
  //int get totalBurn =>
  //    burnBurned +
  //    issueMainBurned +
  //    reissueBurned +
  //    issueSubBurned +
  //    issueUniqueBurned +
  //    issueMessageBurned +
  //    issueQualifierBurned +
  //    issueSubQualifierBurned +
  //    issueRestrictedBurned +
  //    addTagBurned;
//
  ///// asset creation, reissue, send, etc.
  ///// did we sent to burn address? only sent to self?
  //TransactionViewType get type {
  //  // For a more comprehensive check, we should make sure new assets vouts
  //  // actually exist. also how would this work for assets?
  //  TransactionViewType? burned() {
  //    if (isCoin) {
  //      // Must be == not ge, if ge, normal burn since assets are exact
  //      if (issueMainBurned == chaindata.burnAmounts.issueMain) {
  //        return TransactionViewType.createAsset;
  //      }
  //      if (reissueBurned == chaindata.burnAmounts.reissue) {
  //        return TransactionViewType.reissue;
  //      }
  //      if (issueSubBurned == chaindata.burnAmounts.issueSub) {
  //        return TransactionViewType.createSubAsset;
  //      }
  //      if (issueUniqueBurned == chaindata.burnAmounts.issueUnique) {
  //        return TransactionViewType.createNFT;
  //      }
  //      if (issueMessageBurned == chaindata.burnAmounts.issueMessage) {
  //        return TransactionViewType.createMessage;
  //      }
  //      if (issueQualifierBurned == chaindata.burnAmounts.issueQualifier) {
  //        return TransactionViewType.createQualifier;
  //      }
  //      if (issueSubQualifierBurned ==
  //          chaindata.burnAmounts.issueSubQualifier) {
  //        return TransactionViewType.createSubQualifier;
  //      }
  //      if (issueRestrictedBurned == chaindata.burnAmounts.issueRestricted) {
  //        return TransactionViewType.createRestricted;
  //      }
  //      if (addTagBurned == chaindata.burnAmounts.addTag) {
  //        return TransactionViewType.tag;
  //      }
  //    }
  //    if (totalBurn > 0) {
  //      return TransactionViewType.burn;
  //    }
  //    return null;
  //  }
//
  //  final regular = sentToSelf
  //      ? consolidationToSelf
  //          ? TransactionViewType.consolidation
  //          : (isCoin && !containsAssets) || !isCoin
  //              ? TransactionViewType.self
  //              : TransactionViewType.assetTransaction
  //      : iValue > 0
  //          ? TransactionViewType.incoming
  //          : TransactionViewType.outgoing;
  //  final burn = burned();
  //  return burn ?? regular;
  //}
//
  //String get formattedDatetime => height <= 0
  //    ? 'just now'
  //    : formatDate(datetime, <String>[MM, ' ', d, ', ', yyyy]);
  ////{
  ////String ret = formatDate(datetime, <String>[MM, ' ', d, ', ', yyyy]);
  ////if (ret == 'January 1, 0000') {
  ////  ret = 'just now';
  ////}
  ////return ret;
  ////}
}
