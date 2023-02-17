part of 'cubit.dart';

abstract class TitleCubitState extends Equatable {
  final String title;

  const TitleCubitState({required this.title});

  @override
  List<Object> get props => [title];
}

class TitleState extends TitleCubitState {
  const TitleState({required title}) : super(title: title);
}
