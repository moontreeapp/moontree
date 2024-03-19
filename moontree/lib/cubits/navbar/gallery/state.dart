part of 'cubit.dart';

class GalleryState with EquatableMixin {
  final String path;

  const GalleryState({this.path = ''});

  @override
  List<Object?> get props => [path];
}
