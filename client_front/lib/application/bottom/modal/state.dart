part of 'cubit.dart';

abstract class BottomModalSheetCubitState extends Equatable {
  final bool display;
  const BottomModalSheetCubitState(this.display);

  @override
  List<Object> get props => [display];
}

class BottomModalSheetState extends BottomModalSheetCubitState {
  const BottomModalSheetState({required bool display}) : super(display);
}
