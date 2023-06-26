import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'state.dart';

enum ConnectionStatus { connected, connecting, disconnected }

class ConnectionStatusCubit extends Cubit<ConnectionStatusCubitState> {
  ConnectionStatusCubit()
      : super(const ConnectionStatusState(
          status: ConnectionStatus.disconnected,
          busy: false,
        ));

  void update({ConnectionStatus? status, bool? busy}) =>
      emit(ConnectionStatusState(
          status: status ?? state.status, busy: busy ?? state.busy));

  void reset() => emit(ConnectionStatusState(
        status: ConnectionStatus.disconnected,
        busy: false,
      ));

  bool get isConnected => state.status == ConnectionStatus.connected;
}
