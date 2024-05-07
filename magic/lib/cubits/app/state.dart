part of 'cubit.dart';

class AppState with EquatableMixin {
  final String status;
  final StreamingConnectionStatus connection;
  final bool submitting;
  final AppState? prior;

  const AppState({
    this.status = '',
    this.connection = StreamingConnectionStatus.disconnected,
    this.submitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => [
        status,
        connection,
        submitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  AppState get withoutPrior => AppState(
        status: status,
        connection: connection,
        submitting: submitting,
        prior: null,
      );
}
