part of 'cubit.dart';

@immutable
abstract class FrontContainerHeightCubitState extends Equatable {
  final double height;
  final bool hide;
  const FrontContainerHeightCubitState(this.height, [this.hide = false]);

  @override
  List<Object?> get props => [height, hide];

  @override
  String toString() => '$props';
}

class FrontContainerHeightState extends FrontContainerHeightCubitState {
  const FrontContainerHeightState({required double height, bool hide = false})
      : super(height, hide);
}
