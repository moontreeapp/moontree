part of 'cubit.dart';

@immutable
class WalletHoldingViewState {
  final bool reachedTop;
  final bool atBottom;
  final bool isSubmitting;

  const WalletHoldingViewState({
    required this.reachedTop,
    required this.atBottom,
    required this.isSubmitting,
  });

  @override
  String toString() => 'HoldingView( '
      'reachedTop=$reachedTop, atBottom=$atBottom, isSubmitting=$isSubmitting)';

  List<Object?> get props => <Object?>[
        reachedTop,
        atBottom,
        isSubmitting,
      ];

  factory WalletHoldingViewState.initial() => const WalletHoldingViewState(
      reachedTop: false, atBottom: true, isSubmitting: true);

  WalletHoldingViewState load({
    bool? reachedTop,
    bool? atBottom,
    bool? isSubmitting,
  }) =>
      WalletHoldingViewState.load(
        state: this,
        reachedTop: reachedTop,
        atBottom: atBottom,
        isSubmitting: isSubmitting,
      );

  factory WalletHoldingViewState.load({
    required WalletHoldingViewState state,
    bool? reachedTop,
    bool? atBottom,
    bool? isSubmitting,
  }) =>
      WalletHoldingViewState(
        reachedTop: reachedTop ?? state.reachedTop,
        atBottom: atBottom ?? state.atBottom,
        isSubmitting: isSubmitting ?? state.isSubmitting,
      );
}
