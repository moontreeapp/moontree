// ignore_for_file: depend_on_referenced_packages

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/utilities.dart';

part 'state.dart';

class AppbarCubit extends Cubit<AppbarState> with UpdateMixin<AppbarState> {
  AppbarCubit() : super(const AppbarState());
  @override
  void reset() => emit(const AppbarState());
  @override
  void setState(AppbarState state) => emit(state);

  @override
  void update({
    AppbarTitleType? titleType,
    String? title,
  }) {
    emit(AppbarState(
      titleType: titleType ?? state.titleType,
      title: title ?? state.title,
      prior: state.withoutPrior,
    ));
  }
}
