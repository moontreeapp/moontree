import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_back/streams/streams.dart' as back;

part 'state.dart';

enum ConnectionStatus { connected, connecting, disconnected }

class ConnectionStatusCubit extends Cubit<ConnectionStatusCubitState> {
  ConnectionStatusCubit()
      : super(const ConnectionStatusState(
          status: ConnectionStatus.disconnected,
          busy: false,
        )) {
    setupListeners();
  }

  /// we can remove these once we move createClient to the front. until then
  /// it's in the back and the back doesn't have access to the cubits so we need
  /// to listen to the streams it can modify:
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  void setupListeners() {
    listeners.add(back.streams.client.connected.listen((value) {
      update(
          status: value.name == 'connected'
              ? ConnectionStatus.connected
              : value.name == 'connecting'
                  ? ConnectionStatus.connecting
                  : ConnectionStatus.disconnected);
    }));
    listeners.add(back.streams.client.busy.listen((bool value) async {
      update(busy: value);
    }));
  }

  void update({ConnectionStatus? status, bool? busy}) =>
      emit(ConnectionStatusState(
          status: status ?? state.status, busy: busy ?? state.busy));

  void reset() => emit(ConnectionStatusState(
        status: ConnectionStatus.disconnected,
        busy: false,
      ));
}
