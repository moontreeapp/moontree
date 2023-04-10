part of 'cubit.dart';

abstract class SnackbarCubitState extends Equatable {
  final Snack? snack;
  final Snack? prior;

  const SnackbarCubitState(this.snack, this.prior);

  @override
  List<Object?> get props => [snack, prior];
}

class SnackbarState extends SnackbarCubitState {
  const SnackbarState({required Snack? snack, required Snack? prior})
      : super(snack, prior);
}
