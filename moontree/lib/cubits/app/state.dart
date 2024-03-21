part of 'cubit.dart';

class AppLayerState with EquatableMixin {
  final String status;

  final bool submitting;
  final AppLayerState? prior;

  const AppLayerState({
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

  AppLayerState get withoutPrior => AppLayerState(
        status: status,
        submitting: submitting,
        prior: null,
      );
}
