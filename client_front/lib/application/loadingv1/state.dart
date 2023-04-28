part of 'cubit.dart';

enum LoadingStatusV1 {
  // no need to distinguish as of yet
  none, //unknown,
  busy, //waiting,
  /// how to handle 'completed' status? is it a separate enum?
  // failed, // maybe we should have a failedReason, if set to none we can still look that up.
  // succeeded, // usually we'll just set it back to none, because the screen goes away
  // timeout, // instead we should have a LoadingStatusV1Reason str?
}

@immutable
class LoadingViewV1State extends CubitState {
  final LoadingStatusV1 status;
  final bool isSubmitting;

  /// anticipating the need for these in the future:
  //final String? page;
  //final String? timeout;
  //final String? statusHistory; // since .none, example: [(.busy, time), (.waiting, time), (.timeout, time)]
  //final bool dismissable; // perhaps some loading screens are dismissable

  const LoadingViewV1State({
    required this.status,
    required this.isSubmitting,
  });

  @override
  String toString() => 'LoadingViewV1( '
      'status=$status, isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        status,
        isSubmitting,
      ];

  factory LoadingViewV1State.initial() =>
      LoadingViewV1State(status: LoadingStatusV1.none, isSubmitting: true);

  LoadingViewV1State load({LoadingStatusV1? status, bool? isSubmitting}) =>
      LoadingViewV1State(
        status: status ?? this.status,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}
