import 'change.dart';

/// A base class for the source of stored `Record` objects.
/// For example, a HiveSource or other storage mechanism could be subclassed.
abstract class Source<Record> {
  Map<String, Record> initialLoad();

  /// Adds or updates the `model` at a given `key` in the Source.
  Future<Change<Record>?> save(String key, Record record);

  /// Removes a given `key` from the Source.
  Future<Change<Record>?> remove(String key);
}
