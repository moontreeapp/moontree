part of 'cubit.dart';

abstract class TitleCubitState extends Equatable {
  final String title;
  final bool navBack;

  const TitleCubitState({
    required this.title,
    required this.navBack,
  });

  @override
  List<Object> get props => [title, navBack];
}

class TitleState extends TitleCubitState {
  const TitleState({required title, bool navBack = false})
      : super(title: title, navBack: navBack);
}
