import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/server/serverv2_client.dart';
import 'package:magic/utils/log.dart';

part 'state.dart';

class AppCubit extends UpdatableCubit<AppState> {
  AppCubit() : super(const AppState());
  bool animating = false;
  @override
  String get key => 'app';
  @override
  void reset() => emit(const AppState());
  @override
  void setState(AppState state) => emit(state);
  @override
  void refresh() {
    update(submitting: false);
    update(submitting: true);
  }

  @override
  void hide() {
    // TODO: implement hide
  }
  @override
  void activate() => update();
  @override
  void deactivate() => update();

  @override
  void update({
    AppLifecycleState? status,
    StreamingConnectionStatus? connection,
    int? blockheight,
    bool? submitting,
  }) {
    see('blockheight', blockheight, LogColor.yellow);
    emit(AppState(
      status: status ?? state.status,
      connection: connection ?? state.connection,
      blockheight: blockheight ?? state.blockheight,
      submitting: submitting ?? state.submitting,
      prior: state.withoutPrior,
    ));
  }
}
