part of 'cubit.dart';

@immutable
abstract class FrontContainerCubitState extends Equatable {
  final double height;
  final bool hide; // hides the entire front layer.
  final bool hideContent; // hides, rather, fades out the content.
  const FrontContainerCubitState(this.height,
      [this.hide = false, this.hideContent = false]);

  @override
  List<Object?> get props => [height, hide, hideContent];

  @override
  String toString() => '$props';
}

class FrontContainerState extends FrontContainerCubitState {
  const FrontContainerState(
      {required double height, bool hide = false, bool hideContent = false})
      : super(height, hide, hideContent);
}
