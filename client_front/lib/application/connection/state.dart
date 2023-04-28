part of 'cubit.dart';

abstract class ConnectionStatusCubitState extends Equatable {
  final ConnectionStatus status;
  final bool busy;
  const ConnectionStatusCubitState({required this.status, this.busy = false});

  @override
  List<Object?> get props => [status, busy];

  bool get isConnected => status == ConnectionStatus.connected;
}

class ConnectionStatusState extends ConnectionStatusCubitState {
  const ConnectionStatusState({required super.status, super.busy});
}
