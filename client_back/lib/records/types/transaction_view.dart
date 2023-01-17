import 'package:moontree_utils/extensions/extensions.dart';

enum TransactionViewType {
  incoming,
  outgoing,
  fee,
  self,
  consolidation,
  create,
  tag,
  burn,
  reissue,
  claim,
  assetTransaction,
  createAsset,
  createSubAsset,
  createNFT,
  createMessage,
  createQualifier,
  createSubQualifier,
  createRestricted,
}

extension TransactionViewTypeExtension on TransactionViewType {
  String get display {
    switch (this) {
      case TransactionViewType.self:
        return 'Sent to Self';
      case TransactionViewType.consolidation:
        return 'Consolidation';
      case TransactionViewType.incoming:
        return 'Received';
      case TransactionViewType.outgoing:
        return 'Sent';
      case TransactionViewType.fee:
        return 'Transaction Fee';
      case TransactionViewType.assetTransaction:
        return 'Asset Transaction';
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
        return 'Asset Creation';
      case TransactionViewType.createSubAsset:
        return 'Sub Asset Creation';
      case TransactionViewType.createNFT:
        return 'NFT Creation';
      case TransactionViewType.createMessage:
        return 'Message Creation';
      case TransactionViewType.createQualifier:
        return 'Qualifier Creation';
      case TransactionViewType.createSubQualifier:
        return 'Sub Qualifier Creation';
      case TransactionViewType.createRestricted:
        return 'Restricted Creation';
    }
  }

  String get paddedDisplay => (this == TransactionViewType.incoming ||
          this == TransactionViewType.outgoing)
      ? ''
      : '| $display';

  /// here we turn sent to self into fee for fee only and isCoin
  String specialPaddedDisplay([bool feeOnly = false]) =>
      (this == TransactionViewType.incoming ||
              this == TransactionViewType.outgoing)
          ? ''
          : feeOnly
              ? '| Transaction Fee'
              : '| $display';

  String get title => name.toTitleCase();
  String get key => name;
  String get readable => 'chain: $name';
}
