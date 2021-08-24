import 'change.dart';

/// A base class for the source of stored `Record` objects.
/// For example, a HiveSource or other storage mechanism could be subclassed.
abstract class Source<Key extends Object, Record extends Object> {
  Iterable<Record> initialLoad();

  /// Adds or updates the `model` at a given `key` in the Source.
  Future<Change?> save(Key key, Record model);

  /// Removes a given `key` from the Source.
  Future<Change?> remove(Key key);
}
