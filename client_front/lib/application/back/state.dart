part of 'cubit.dart';

@immutable
abstract class BackContainerCubitState extends Equatable {
  final double height;
  final String path;
  final String priorPath;
  const BackContainerCubitState({
    required this.height,
    required this.path,
    required this.priorPath,
  });

  @override
  List<Object?> get props => [height, path];

  bool get menuExpanded => path.startsWith('/menu/');
}

class BackContainerState extends BackContainerCubitState {
  const BackContainerState({
    required super.height,
    required super.path,
    required super.priorPath,
  });
}
