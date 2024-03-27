// ignore_for_file: depend_on_referenced_packages

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/mixins.dart';

part 'state.dart';

class AppbarCubit extends Cubit<AppbarState> with UpdateMixin<AppbarState> {
  AppbarCubit() : super(const AppbarState());
  @override
  String get key => 'appbar';
  @override
  void reset() => emit(const AppbarState());
  @override
  void setState(AppbarState state) => emit(state);

  @override
  void update({
    AppbarLeading? leading,
    String? title,
  }) {
    emit(AppbarState(
      leading: leading ?? state.leading,
      title: title ?? state.title,
      prior: state.withoutPrior,
    ));
  }
}
