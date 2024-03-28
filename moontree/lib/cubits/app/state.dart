part of 'cubit.dart';

class AppState with EquatableMixin {
  final String status;
  final bool submitting;
  final AppState? prior;

  const AppState({
    this.status = '',
    this.submitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => [
        status,
        submitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  AppState get withoutPrior => AppState(
        status: status,
        submitting: submitting,
        prior: null,
      );
}
