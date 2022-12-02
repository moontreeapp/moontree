import 'package:equatable/equatable.dart';

mixin SetCubitMixin {
  CubitState submitting();

  void enter();

  void reset();

  void set();
}

class CubitState with EquatableMixin {
  const CubitState({this.isSubmitting = false});

  factory CubitState.load({required CubitState form, bool? isSubmitting}) =>
      CubitState(isSubmitting: isSubmitting ?? form.isSubmitting);

  factory CubitState.initial() => const CubitState();
  final bool isSubmitting;

  @override
  String toString() => 'CubitState(isSubmitting=$isSubmitting)';

  @override
  List<Object> get props => <Object>[isSubmitting];

  CubitState load({bool? isSubmitting}) =>
      CubitState.load(form: this, isSubmitting: isSubmitting);

  //import 'package:moontree_utils/zips.dart' show zipLists;
  //@override
  //bool operator ==(Object other) =>
  //    other.runtimeType == this.runtimeType &&
  //    zipLists([this.props, (other as CubitState).props])
  //        .every((e) => e.first == e.last);
}
