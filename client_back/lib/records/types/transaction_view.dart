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
        return 'Create Asset';
      case TransactionViewType.createSubAsset:
        return 'Create Sub Asset';
      case TransactionViewType.createNFT:
        return 'Create NFT';
      case TransactionViewType.createMessage:
        return 'Create Message';
      case TransactionViewType.createQualifier:
        return 'Create Qualifier';
      case TransactionViewType.createSubQualifier:
        return 'Create Sub Qualifier';
      case TransactionViewType.createRestricted:
        return 'Create Restricted';
    }
  }

  String get paddedDisplay => (this == TransactionViewType.incoming ||
          this == TransactionViewType.outgoing)
      ? ''
      : '| $display';

  String get title => name.toTitleCase();
  String get key => name;
  String get readable => 'chain: $name';
}
