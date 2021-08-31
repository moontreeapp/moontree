/// we may just want to hold on to the most recent header instead of saving multiple...
import 'package:collection/collection.dart';
import 'package:raven/records/records.dart';
import 'package:reservoir/reservoir.dart';

part 'block.keys.dart';

class BlockReservoir extends Reservoir<_HeaderKey, Block> {
  late IndexMultiple<_HeaderKey, Block> byHeader;

  BlockReservoir([source])
      : super(source ?? HiveSource('blocks'), _HeaderKey()) {
    byHeader = addIndexMultiple('header', _HeaderKey());
  }

  // assuming most recent on the end of the list...
  Block? get latestBlock => data.lastOrNull;
}
