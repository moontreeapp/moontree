import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';

part 'state.dart';

class FadeCubit extends Cubit<FadeState> with UpdateMixin<FadeState> {
  FadeCubit() : super(const FadeState());
  @override
  String get key => 'ignore';
  @override
  void reset() => emit(const FadeState());
  @override
  void setState(FadeState state) => emit(state);
  @override
  void refresh() {
  }
  @override
  void update({FadeEvent? fade}) {
    emit(FadeState(fade: fade ?? state.fade));
  }
}
