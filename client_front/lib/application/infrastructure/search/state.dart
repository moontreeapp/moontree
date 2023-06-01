part of 'cubit.dart';

abstract class SearchCubitState extends Equatable {
  final String text;
  final bool show;

  const SearchCubitState({this.text = '', this.show = false});

  @override
  List<Object?> get props => [text, show];

  bool get showSearchButton => components.cubits.location.showSearchButton;
}

class SearchState extends SearchCubitState {
  const SearchState({super.text, super.show});
}
