import 'change.dart';
import 'reservoir.dart';

/// A base class for the source of stored `Record` objects.
/// For example, a HiveSource or other storage mechanism could be subclassed.
abstract class Source<Key, Record, Model> {
  /// The `watch` method is responsible for 2 things:
  /// 1. adding, updating, and removing key/value pairs in the Reservoir, and
  /// 2. returning a stream of changes that match the action taken.
  Stream<Change> watch(Reservoir<Key, Record, Model> reservoir);

  /// Adds or updates the `model` at a given `key` in the Source.
  /// It's reasonable for `key` to be a column on `model` (e.g. account ID),
  /// but not required.
  void save(Key key, Record model);

  /// Removes a given `key` from the Source.
  void remove(Key key);
}
