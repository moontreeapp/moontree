part of 'cubit.dart';

@immutable
class HoldingViewState {
  final bool reachedTop;
  final bool atBottom;
  final bool isSubmitting;

  const HoldingViewState({
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

  factory HoldingViewState.initial() => const HoldingViewState(
      reachedTop: false, atBottom: true, isSubmitting: true);

  HoldingViewState load({
    bool? reachedTop,
    bool? atBottom,
    bool? isSubmitting,
  }) =>
      HoldingViewState.load(
        state: this,
        reachedTop: reachedTop,
        atBottom: atBottom,
        isSubmitting: isSubmitting,
      );

  factory HoldingViewState.load({
    required HoldingViewState state,
    bool? reachedTop,
    bool? atBottom,
    bool? isSubmitting,
  }) =>
      HoldingViewState(
        reachedTop: reachedTop ?? state.reachedTop,
        atBottom: atBottom ?? state.atBottom,
        isSubmitting: isSubmitting ?? state.isSubmitting,
      );
}
