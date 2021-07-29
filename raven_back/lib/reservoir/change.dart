import 'package:equatable/equatable.dart';

/// The Change class is an ADT, meaning we're using the Dart type system
/// at compile time to help us check that we're considering all possible
/// kinds of change: Added, Updated, Removed
abstract class Change with EquatableMixin {
  Object id;

  Change(this.id);

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
  dynamic data;
  Added(id, this.data) : super(id);

  @override
  String toString() => 'Added($id: $data)';
}

class Updated extends Change {
  dynamic data;
  Updated(id, this.data) : super(id);

  @override
  String toString() => 'Updated($id: $data)';
}

class Removed extends Change {
  Removed(id) : super(id);

  @override
  String toString() => 'Removed($id)';
}
