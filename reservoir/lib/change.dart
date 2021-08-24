import 'package:equatable/equatable.dart';

/// The Change class is an ADT, meaning we're using the Dart type system
/// at compile time to help us check that we're considering all possible
/// kinds of change: Added, Updated, Removed
abstract class Change<Record> with EquatableMixin {
  Object id;
  Record data;

  Change(this.id, this.data);

  T when<T>(
      {required T Function(Added) added,
      required T Function(Updated) updated,
      required T Function(Removed) removed}) {
    if (this is Added) return added(this as Added);
    if (this is Updated) return updated(this as Updated);
    if (this is Removed) return removed(this as Removed);
    throw Exception('Invalid Change');
  }

  @override
  List<Object> get props => [id];
}

class Added extends Change {
  Added(id, data) : super(id, data);

  @override
  String toString() => 'Added($id: $data)';
}

class Updated extends Change {
  Updated(id, data) : super(id, data);

  @override
  String toString() => 'Updated($id: $data)';
}

class Removed extends Change {
  Removed(id, data) : super(id, data);

  @override
  String toString() => 'Removed($id: $data)';
}
