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
class LoadingViewState extends CubitState {
  final LoadingStatus status;
  final bool isSubmitting;

  /// anticipating the need for these in the future:
  //final String? page;
  //final String? timeout;
  //final String? statusHistory; // since .none, example: [(.busy, time), (.waiting, time), (.timeout, time)]
  //final bool dismissable; // perhaps some loading screens are dismissable

  const LoadingViewState({
    required this.status,
    required this.isSubmitting,
  });

  @override
  String toString() => 'LoadingView( '
      'status=$status, isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        status,
        isSubmitting,
      ];

  factory LoadingViewState.initial() =>
      LoadingViewState(status: LoadingStatus.none, isSubmitting: true);

  LoadingViewState load({LoadingStatus? status, bool? isSubmitting}) =>
      LoadingViewState(
        status: status ?? this.status,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}
