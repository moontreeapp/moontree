import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';

part 'state.dart';

class IgnoreCubit extends Cubit<IgnoreState> with UpdateMixin<IgnoreState> {
  IgnoreCubit() : super(const IgnoreState());
  @override
  String get key => 'ignore';
  @override
  void reset() => emit(const IgnoreState());
  @override
  void setState(IgnoreState state) => emit(state);
  @override
  void refresh() {}

  @override
  void update({bool? active}) {
    emit(IgnoreState(active: active ?? state.active));
  }
}
