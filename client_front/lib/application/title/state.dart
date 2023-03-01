part of 'cubit.dart';

abstract class TitleCubitState extends Equatable {
  final String? title;
  const TitleCubitState({this.title});

  @override
  List<Object?> get props => [title];
}

class TitleState extends TitleCubitState {
  const TitleState({super.title});
}
