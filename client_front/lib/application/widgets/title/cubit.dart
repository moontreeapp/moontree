import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'state.dart';

class TitleCubit extends Cubit<TitleCubitState> {
  TitleCubit() : super(const TitleState(title: "Holdings", navBack: false));

  void update({String? title, bool? navBack}) => emit(TitleState(
        title: title ?? state.title,
        navBack: navBack ?? state.navBack,
      ));
}
