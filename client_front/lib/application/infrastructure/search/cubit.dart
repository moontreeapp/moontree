import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

part 'state.dart';

class SearchCubit extends Cubit<SearchCubitState> {
  SearchCubit() : super(const SearchState());

  void update({String? text, bool? show}) => emit(SearchState(
        text: text ?? state.text,
        show: show ?? state.show,
      ));

  void reset() => emit(SearchState());

  void toggleSearch() => update(text: '', show: !state.show);

  bool get shown => state.show;
  bool get searchButtonShown => state.searchButtonShown;
}
