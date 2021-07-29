import 'change.dart';
import 'reservoir.dart';

abstract class Source<Record, Model> {
  /// The `watch` method is responsible for 2 things:
  /// 1. adding, updating, and removing key/value pairs in the Reservoir, and
  /// 2. returning a stream of changes that match the action taken.
  Stream<Change> watch(Reservoir<Record, Model> reservoir);

  void save(key, Record record);
}
