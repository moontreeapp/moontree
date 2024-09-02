part of 'cubit.dart';

class KeysState with EquatableMixin {
  final List<String> xpubs;
  final List<String> mnemonics;
  final List<String> wifs;
  final bool submitting;
  final KeysState? prior;

  const KeysState({
    required this.xpubs,
    required this.mnemonics,
    required this.wifs,
    this.submitting = false,
    this.prior,
  });

  factory KeysState.empty() =>
      const KeysState(xpubs: [], mnemonics: [], wifs: []);

  @override
  List<Object?> get props => [
        xpubs,
        mnemonics,
        wifs,
        submitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  KeysState get withoutPrior => KeysState(
        xpubs: xpubs,
        mnemonics: mnemonics,
        wifs: wifs,
        submitting: submitting,
        prior: null,
      );
}
