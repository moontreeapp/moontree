part of 'cubit.dart';

abstract class TitleCubitState extends Equatable {
  final String path;
  final String? title;

  const TitleCubitState({
    required this.path,
    this.title,
  });

  @override
  List<Object?> get props => [path, title];
}

class TitleState extends TitleCubitState {
  const TitleState({required String path, String? title})
      : super(path: path, title: title);
}
