part of 'cubit.dart';

class TutorialState with EquatableMixin {
  final List<TutorialStatus> showTutorials;
  final bool flicked; // this should be a tutorial itself, but for now it's bool
  const TutorialState({required this.showTutorials, required this.flicked});

  @override
  List<Object> get props => [showTutorials];
}
