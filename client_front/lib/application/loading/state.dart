part of 'cubit.dart';

enum LoadingStatus {
  unknown,
  none,
  busy, //waiting, // no need to distinguish as of yet
  failed,
  succeeded,
}

@immutable
class LoadingViewState extends CubitState {
  final LoadingStatus status;
  final String? page;
  final bool isSubmitting;

  const LoadingViewState({
    required this.status,
    required this.page,
    required this.isSubmitting,
  });

  @override
  String toString() => 'LoadingView( '
      'status=$status, page=$page, isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        status,
        page,
        isSubmitting,
      ];

  factory LoadingViewState.initial() => LoadingViewState(
      status: LoadingStatus.none, page: null, isSubmitting: true);

  LoadingViewState load({
    LoadingStatus? status,
    String? page,
    bool? isSubmitting,
  }) =>
      LoadingViewState.load(
        state: this,
        status: status,
        page: page,
        isSubmitting: isSubmitting,
      );

  factory LoadingViewState.load({
    required LoadingViewState state,
    LoadingStatus? status,
    String? page,
    bool? isSubmitting,
  }) =>
      LoadingViewState(
        status: status ?? state.status,
        page: page ?? state.page,
        isSubmitting: isSubmitting ?? state.isSubmitting,
      );
}
