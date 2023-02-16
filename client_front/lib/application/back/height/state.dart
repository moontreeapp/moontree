part of 'cubit.dart';

@immutable
abstract class BackContainerHeightCubitState extends Equatable {
  final double height;
  const BackContainerHeightCubitState(this.height);

  @override
  List<Object?> get props => [height];
}

class BackContainerHeightState extends BackContainerHeightCubitState {
  const BackContainerHeightState({required double height}) : super(height);
}
