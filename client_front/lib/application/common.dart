import 'package:equatable/equatable.dart';

mixin SetCubitMixin {
  CubitState submitting();

  void enter();

  void reset();

  void set();
}

class CubitState with EquatableMixin {
  const CubitState();

  factory CubitState.load({required CubitState form}) => CubitState();

  factory CubitState.initial() => const CubitState();

  @override
  String toString() => 'CubitState()';

  @override
  List<Object?> get props => <Object?>[];

  CubitState load() => CubitState.load(form: this);

  //import 'package:moontree_utils/zips.dart' show zipLists;
  //@override
  //bool operator ==(Object other) =>
  //    other.runtimeType == this.runtimeType &&
  //    zipLists([this.props, (other as CubitState).props])
  //        .every((e) => e.first == e.last);
}
