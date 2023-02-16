part of 'cubit.dart';

enum LoadingStatusv2 {
  // no need to distinguish as of yet
  none, //unknown,
  busy, //waiting,
  /// how to handle 'completed' status? is it a separate enum?
  // failed, // maybe we should have a failedReason, if set to none we can still look that up.
  // succeeded, // usually we'll just set it back to none, because the screen goes away
  // timeout, // instead we should have a LoadingStatusReason str?
}

@immutable
class LoadingViewStatev2 {
  final LoadingStatusv2 status;
  final LoadingStatusv2 priorStatus;
  final bool isSubmitting;

  /// anticipating the need for these in the future:
  //final String? page;
  //final String? timeout;
  //final String? statusHistory; // since .none, example: [(.busy, time), (.waiting, time), (.timeout, time)]
  //final bool dismissable; // perhaps some loading screens are dismissable

  const LoadingViewStatev2({
    required this.status,
    required this.priorStatus,
    required this.isSubmitting,
  });

  @override
  String toString() => 'LoadingView( '
      'status=$status, priorStatus=$priorStatus, isSubmitting=$isSubmitting)';

  List<Object?> get props => <Object?>[
        status,
        priorStatus,
        isSubmitting,
      ];

  factory LoadingViewStatev2.initial() => const LoadingViewStatev2(
      status: LoadingStatusv2.none,
      priorStatus: LoadingStatusv2.none,
      isSubmitting: true);

  LoadingViewStatev2 load({
    LoadingStatusv2? status,
    LoadingStatusv2? priorStatus,
    bool? isSubmitting,
  }) =>
      LoadingViewStatev2.load(
        state: this,
        status: status,
        priorStatus: priorStatus,
        isSubmitting: isSubmitting,
      );

  factory LoadingViewStatev2.load({
    required LoadingViewStatev2 state,
    LoadingStatusv2? status,
    LoadingStatusv2? priorStatus,
    bool? isSubmitting,
  }) =>
      LoadingViewStatev2(
        status: status ?? state.status,
        priorStatus: priorStatus ?? state.priorStatus,
        isSubmitting: isSubmitting ?? state.isSubmitting,
      );
}
