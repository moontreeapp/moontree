import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moontree/cubits/utilities.dart';

part 'state.dart';

class IgnoreCubit extends Cubit<IgnoreState> with UpdateMixin<IgnoreState> {
  int counter = 0;
  IgnoreCubit() : super(const IgnoreState());
  @override
  String get key => 'ignore';
  @override
  void reset() => emit(const IgnoreState());
  @override
  void setState(IgnoreState state) => emit(state);

  @override
  void update({
    bool? active,
  }) {
    counter++;
    emit(IgnoreState(
      active: active ?? state.active,
    ));
  }
}
