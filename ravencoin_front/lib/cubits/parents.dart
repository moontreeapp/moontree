import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

abstract class SetCubit<T> extends Cubit with SetCubitMixin {
  SetCubit(initialState) : super(initialState);

  T submitting() => state.load(isSubmitting: true);

  void enter() async => emit(state);

  Future<CubitState> set();
  //void submit() async {
  //  emit(await submitSend());
  //}
}

mixin SetCubitMixin {
  Future<CubitState> set();
}

class CubitState with EquatableMixin {
  final myType = CubitState;
  final bool isSubmitting;

  const CubitState({this.isSubmitting = false});

  @override
  String toString() => 'CubitState(isSubmitting=$isSubmitting)';

  @override
  List<Object> get props => [isSubmitting];

  factory CubitState.initial() => CubitState(isSubmitting: false);

  CubitState load({bool? isSubmitting}) =>
      CubitState.load(form: this, isSubmitting: isSubmitting);

  factory CubitState.load({required CubitState form, bool? isSubmitting}) =>
      CubitState(isSubmitting: isSubmitting ?? form.isSubmitting);

  //import 'package:moontree_utils/zips.dart' show zipLists;
  //@override
  //bool operator ==(Object other) =>
  //    other.runtimeType == this.runtimeType &&
  //    zipLists([this.props, (other as CubitState).props])
  //        .every((e) => e.first == e.last);
}
