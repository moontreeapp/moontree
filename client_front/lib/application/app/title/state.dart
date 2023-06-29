part of 'cubit.dart';

abstract class TitleCubitState extends Equatable {
  final String? title;
  final bool editable;
  final bool submitting;
  const TitleCubitState({
    this.title,
    this.editable = false,
    this.submitting = false,
  });

  @override
  List<Object?> get props => [title, editable, submitting];
}

class TitleState extends TitleCubitState {
  const TitleState({super.title, super.editable, super.submitting});
}
