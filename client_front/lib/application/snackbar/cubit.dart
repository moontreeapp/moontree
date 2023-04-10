// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:client_back/streams/app.dart';
import 'package:equatable/equatable.dart';
import 'package:client_back/streams/streams.dart' as back;

part 'state.dart';

class SnackbarCubit extends Cubit<SnackbarCubitState> {
  SnackbarCubit() : super(SnackbarState(snack: null, prior: null)) {
    setupListener();
  }

  Future<void> countdownTimer(int seconds) =>
      Future.delayed(Duration(seconds: seconds));

  Future<void> runAsyncFunction() async => clear();

  /// we can remove these once we never make a snackbar from back processes such
  /// as import processes. until then we make this cubit responsive to the
  /// stream:
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  void setupListener() =>
      listeners.add(back.streams.app.snack.listen((Snack? value) {
        _update(snack: value, prior: state.snack);
        if (value != null) {
          countdownTimer(value.seconds).then((_) {
            runAsyncFunction();
          });
        }
      }));

  // don't use this function on pages for this cubit.
  void _update({required Snack? snack, required Snack? prior}) =>
      emit(SnackbarState(snack: snack, prior: prior));

  void show({required Snack? snack}) =>
      _update(snack: snack, prior: state.snack);
  //void hide() => update(snack: null);
  void clear() => _update(snack: null, prior: state.snack);
}
