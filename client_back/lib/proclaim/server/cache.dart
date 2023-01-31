import 'package:client_back/records/server/cache.dart';
import 'package:client_back/records/types/chain.dart';
import 'package:client_back/records/types/net.dart';
import 'package:proclaim/proclaim.dart';

part 'cache.keys.dart';

class CacheProclaim extends Proclaim<_IdKey, CachedServerObject> {
  late IndexMultiple<_HoldingKey, CachedServerObject> byHolding;

  CacheProclaim() : super(_IdKey()) {
    byHolding = addIndexMultiple('byHolding', _HoldingKey());
  }

  /// an alias
  IndexUnique<_IdKey, CachedServerObject> get open => super.primaryIndex;
}
