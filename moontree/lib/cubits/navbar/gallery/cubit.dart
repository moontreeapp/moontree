import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moontree/cubits/utilities.dart';

part 'state.dart';

class GalleryCubit extends Cubit<GalleryState> with UpdateMixin<GalleryState> {
  GalleryCubit() : super(const GalleryState());

  @override
  void reset() => emit(const GalleryState());
  @override
  void setState(GalleryState state) => emit(state);

  @override
  void update({String? path}) {
    emit(GalleryState(
      path: path ?? state.path,
    ));
  }
}
