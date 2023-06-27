part of 'cubit.dart';

enum LoadingStatus {
  // no need to distinguish as of yet
  none, //unknown,
  busy, //waiting,
  /// how to handle 'completed' status? is it a separate enum?
  // failed, // maybe we should have a failedReason, if set to none we can still look that up.
  // succeeded, // usually we'll just set it back to none, because the screen goes away
  // timeout, // instead we should have a LoadingStatusReason str?
}

@immutable
class LoadingViewState {
  final LoadingStatus status;
  final LoadingStatus priorStatus;
  final String? title;
  final String? msg;
  final bool isSubmitting;

  /// anticipating the need for these in the future:
  //final String? page;
  //final String? timeout;
  //final String? statusHistory; // since .none, example: [(.busy, time), (.waiting, time), (.timeout, time)]
  //final bool dismissable; // perhaps some loading screens are dismissable

  const LoadingViewState({
    required this.status,
    required this.priorStatus,
    required this.title,
    required this.msg,
    required this.isSubmitting,
  });

  @override
  String toString() => 'LoadingView( '
      'status=$status, priorStatus=$priorStatus, title=$title, msg=$msg, '
      'isSubmitting=$isSubmitting)';

  List<Object?> get props => <Object?>[
        status,
        priorStatus,
        isSubmitting,
        title,
        msg,
      ];

  factory LoadingViewState.initial() => const LoadingViewState(
      status: LoadingStatus.none,
      priorStatus: LoadingStatus.none,
      title: null,
      msg: null,
      isSubmitting: true);

  LoadingViewState load({
    LoadingStatus? status,
    LoadingStatus? priorStatus,
    String? title,
    String? msg,
    bool? isSubmitting,
  }) =>
      LoadingViewState.load(
        state: this,
        status: status,
        priorStatus: priorStatus,
        title: title,
        msg: msg,
        isSubmitting: isSubmitting,
      );

  factory LoadingViewState.load({
    required LoadingViewState state,
    LoadingStatus? status,
    LoadingStatus? priorStatus,
    String? title,
    String? msg,
    bool? isSubmitting,
  }) =>
      LoadingViewState(
        status: status ?? state.status,
        priorStatus: priorStatus ?? state.priorStatus,
        title: title ?? state.title,
        msg: msg ?? state.msg,
        isSubmitting: isSubmitting ?? state.isSubmitting,
      );
}
