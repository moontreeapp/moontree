import 'package:raven/subjects/change.dart';
import 'package:raven/subjects/reservoir.dart';
import 'package:raven/subjects/source.dart';

import 'rx_map.dart';

class RxMapSource<Record, Model> extends Source<Record, Model> {
  final RxMap map = RxMap();

  @override
  Stream<Change> watch(Reservoir reservoir) {
    return map.stream.map((Change event) => event.when(
        added: (added) => reservoir.addRecord(added.id, added.data),
        updated: (updated) => reservoir.updateRecord(updated.id, updated.data),
        removed: (removed) => reservoir.removeRecord(removed.id)));
  }

  @override
  void save(key, Record record) {
    map[key] = record;
  }
}
