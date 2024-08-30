part of 'cubit.dart';

class KeysState with EquatableMixin {
  final List<String> mnemonics;
  final List<String> wifs;
  final bool submitting;
  final KeysState? prior;

  const KeysState({
    required this.mnemonics,
    required this.wifs,
    this.submitting = false,
    this.prior,
  });

  factory KeysState.empty() => const KeysState(mnemonics: [], wifs: []);

  @override
  List<Object?> get props => [
        mnemonics,
        wifs,
        submitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  KeysState get withoutPrior => KeysState(
        mnemonics: mnemonics,
        wifs: wifs,
        submitting: submitting,
        prior: null,
      );
}
