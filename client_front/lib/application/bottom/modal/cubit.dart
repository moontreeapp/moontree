// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'state.dart';

class BottomModalSheetCubit extends Cubit<BottomModalSheetCubitState> {
  BottomModalSheetCubit() : super(const BottomModalSheetState(display: false));

  void show() {
    emit(const BottomModalSheetState(display: true));
  }

  void hide() {
    emit(const BottomModalSheetState(display: false));
  }
}
