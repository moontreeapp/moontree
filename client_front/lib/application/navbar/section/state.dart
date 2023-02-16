part of 'cubit.dart';

abstract class NavbarSectionCubitState extends Equatable {
  final bool showSections;
  const NavbarSectionCubitState(this.showSections);

  @override
  List<Object> get props => [showSections];
}

class NavbarSectionState extends NavbarSectionCubitState {
  const NavbarSectionState({required bool show}) : super(show);
}
