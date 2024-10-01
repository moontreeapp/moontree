part of 'cubit.dart';

class KeysState with EquatableMixin {
  final List<Map<String, Map<String, String>>> xpubs;
  final List<Map<String, String>>? xpubsKP;
  final List<String> mnemonics;
  final List<String> wifs;
  final bool submitting;
  final KeysState? prior;

  const KeysState({
    required this.xpubs,
    required this.xpubsKP,
    required this.mnemonics,
    required this.wifs,
    this.submitting = false,
    this.prior,
  });

  factory KeysState.empty() =>
      const KeysState(xpubs: [], xpubsKP: [], mnemonics: [], wifs: []);

  @override
  List<Object?> get props => [
        xpubs,
        xpubsKP,
        mnemonics,
        wifs,
        submitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  KeysState get withoutPrior => KeysState(
        xpubs: xpubs,
        xpubsKP: xpubsKP,
        mnemonics: mnemonics,
        wifs: wifs,
        submitting: submitting,
        prior: null,
      );
}
