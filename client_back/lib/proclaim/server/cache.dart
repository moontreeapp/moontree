import 'package:client_back/records/server/cache.dart';
import 'package:client_back/records/types/chain.dart';
import 'package:client_back/records/types/net.dart';
import 'package:collection/collection.dart';
import 'package:proclaim/proclaim.dart';

part 'cache.keys.dart';

class CacheProclaim extends Proclaim<_IdKey, CachedServerObject> {
  late IndexMultiple<_TypeKey, CachedServerObject> byType;
  late IndexMultiple<_HoldingKey, CachedServerObject> byHolding;
  late IndexMultiple<_AssetMetadataKey, CachedServerObject> byAssetMetadata;
  late IndexMultiple<_CirculatingSatsKey, CachedServerObject> byCirculatingSats;
  late IndexMultiple<_TransactionDetailKey, CachedServerObject>
      byTransactionDetail;
  late IndexMultiple<_TransactionsKey, CachedServerObject> byTransactions;
  late IndexMultiple<_TransactionsByHeightKey, CachedServerObject>
      byTransactionsByHeight;

  CacheProclaim() : super(_IdKey()) {
    byType = addIndexMultiple('byType', _TypeKey());
    byHolding = addIndexMultiple('byHolding', _HoldingKey());
    byAssetMetadata = addIndexMultiple('byAssetMetadata', _AssetMetadataKey());
    byCirculatingSats =
        addIndexMultiple('byCirculatingSats', _CirculatingSatsKey());
    byTransactionDetail =
        addIndexMultiple('byTransactionDetail', _TransactionDetailKey());
    byTransactions = addIndexMultiple('byTransactions', _TransactionsKey());
    byTransactionsByHeight =
        addIndexMultiple('byTransactionsByHeight', _TransactionsByHeightKey());
  }

  /// an alias
  IndexUnique<_IdKey, CachedServerObject> get open => super.primaryIndex;
}
