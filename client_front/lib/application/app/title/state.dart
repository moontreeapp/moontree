part of 'cubit.dart';

abstract class TitleCubitState extends Equatable {
  final String? title;
  final bool editable;
  const TitleCubitState({this.title, this.editable = false});

  @override
  List<Object?> get props => [title, editable];
}

class TitleState extends TitleCubitState {
  const TitleState({super.title, super.editable});
}
