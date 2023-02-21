part of 'cubit.dart';

@immutable
abstract class BackContainerCubitState extends Equatable {
  final double height;
  final Widget child;
  const BackContainerCubitState(
    this.height,
    this.child,
  );

  @override
  List<Object?> get props => [height, child];
}

class BackContainerState extends BackContainerCubitState {
  const BackContainerState({required double height, required Widget child})
      : super(height, child);
}
