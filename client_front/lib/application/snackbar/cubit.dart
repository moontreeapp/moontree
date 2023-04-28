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

  Future<void> runAsyncFunction(void Function() fn) async => fn();

  /// we can remove these once we never make a snackbar from back processes such
  /// as import processes. until then we make this cubit responsive to the
  /// stream:
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  void setupListener() =>
      listeners.add(back.streams.app.behavior.snack.listen((Snack? value) {
        if (value != null) {
          if (value.delay > 0) {
            countdownTimer(value.delay).then((_) {
              runAsyncFunction(() => _update(snack: value, prior: state.snack));
            });
          } else {
            _update(snack: value, prior: state.snack);
          }
          if (value.seconds > 0) {
            countdownTimer(value.seconds).then((_) {
              runAsyncFunction(clear);
            });
          } else {
            // should we clear it by default?
            countdownTimer(10).then((_) {
              runAsyncFunction(clear);
            });
          }
        }
      }));

  /// this update function acts differently than normal, requiring all params
  void _update({required Snack? snack, required Snack? prior}) =>
      emit(SnackbarState(snack: snack, prior: prior));

  void show({required Snack? snack}) => (snack?.delay ?? 0) > 0
      ? countdownTimer(snack!.delay).then((_) {
          runAsyncFunction(() => _update(snack: snack, prior: state.snack));
        })
      : _update(snack: snack, prior: state.snack);
  //void hide() => update(snack: null);
  void clear() => _update(snack: null, prior: state.snack);
}
