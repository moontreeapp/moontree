part of 'cubit.dart';

@immutable
class ManageHoldingViewState {
  final bool reachedTop;
  final bool atBottom;
  final bool isSubmitting;

  const ManageHoldingViewState({
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

  factory ManageHoldingViewState.initial() => const ManageHoldingViewState(
      reachedTop: false, atBottom: true, isSubmitting: true);

  ManageHoldingViewState load({
    bool? reachedTop,
    bool? atBottom,
    bool? isSubmitting,
  }) =>
      ManageHoldingViewState.load(
        state: this,
        reachedTop: reachedTop,
        atBottom: atBottom,
        isSubmitting: isSubmitting,
      );

  factory ManageHoldingViewState.load({
    required ManageHoldingViewState state,
    bool? reachedTop,
    bool? atBottom,
    bool? isSubmitting,
  }) =>
      ManageHoldingViewState(
        reachedTop: reachedTop ?? state.reachedTop,
        atBottom: atBottom ?? state.atBottom,
        isSubmitting: isSubmitting ?? state.isSubmitting,
      );
}
