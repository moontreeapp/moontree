import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
part 'state.dart';

class ExtraContainerCubit extends Cubit<ExtraContainerState> {
  String? priorPage;

  ExtraContainerCubit() : super(ExtraContainerState.initial());

  void reset() => emit(ExtraContainerState.initial());

  void enter() => emit(state);

  void set({Widget? child}) => child == null
      ? emit(ExtraContainerState.initial())
      : emit(state.load(child: child));
}
