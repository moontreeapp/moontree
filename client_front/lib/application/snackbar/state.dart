part of 'cubit.dart';

abstract class SnackbarCubitState extends Equatable {
  final bool showSections;
  final double height;
  final SnackbarHeight currentSnackbarHeight;
  final SnackbarHeight previousSnackbarHeight;

  const SnackbarCubitState(
    this.showSections,
    this.height,
    this.previousSnackbarHeight,
    this.currentSnackbarHeight,
  );

  @override
  List<Object> get props => [
        showSections,
        height,
        previousSnackbarHeight,
        currentSnackbarHeight,
      ];
}

class SnackbarState extends SnackbarCubitState {
  const SnackbarState({
    required bool showSections,
    required double height,
    required SnackbarHeight previousSnackbarHeight,
    required SnackbarHeight currentSnackbarHeight,
  }) : super(
          showSections,
          height,
          previousSnackbarHeight,
          currentSnackbarHeight,
        );
}
