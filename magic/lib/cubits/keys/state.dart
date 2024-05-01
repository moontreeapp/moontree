part of 'cubit.dart';

class KeysState with EquatableMixin {
  final String key;
  final bool submitting;
  final KeysState? prior;

  const KeysState({
    this.key = '',
    this.submitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => [
        key,
        submitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  KeysState get withoutPrior => KeysState(
        key: key,
        submitting: submitting,
        prior: null,
      );
}
