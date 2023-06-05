part of 'cubit.dart';

abstract class SearchCubitState extends Equatable {
  final String text;
  final bool show;

  const SearchCubitState({this.text = '', this.show = false});

  @override
  List<Object?> get props => [text, show];

  bool get searchButtonShown => components.cubits.location.searchButtonShown;
}

class SearchState extends SearchCubitState {
  const SearchState({super.text, super.show});
}
