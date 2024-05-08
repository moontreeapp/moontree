part of 'cubit.dart';

class AppState with EquatableMixin {
  final String status;
  final StreamingConnectionStatus connection;
  final int blockheight;
  final bool submitting;
  final AppState? prior;

  const AppState({
    this.status = '',
    this.connection = StreamingConnectionStatus.disconnected,
    this.blockheight = 0,
    this.submitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => [
        status,
        connection,
        blockheight,
        submitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  AppState get withoutPrior => AppState(
        status: status,
        connection: connection,
        blockheight: blockheight,
        submitting: submitting,
        prior: null,
      );
}
