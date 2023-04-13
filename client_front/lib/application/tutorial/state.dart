part of 'cubit.dart';

abstract class TutorialCubitState extends Equatable {
  final List<TutorialStatus> showTutorials;
  const TutorialCubitState({required this.showTutorials});

  @override
  List<Object> get props => [showTutorials];
}

class TutorialState extends TutorialCubitState {
  const TutorialState({required super.showTutorials});
}
