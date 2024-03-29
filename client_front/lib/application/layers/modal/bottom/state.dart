part of 'cubit.dart';

abstract class BottomModalSheetCubitState extends Equatable {
  /// used to trigger display
  final bool display;

  /// used for exiting animations
  final bool exiting;

  /// should be ListTitle with an icon of 24x24
  final List<Widget> children;

  final int childrenHeight;
  final bool fullscreen;
  final Color color;

  const BottomModalSheetCubitState({
    required this.display,
    required this.exiting,
    required this.children,
    this.childrenHeight = 52,
    this.fullscreen = false,
    this.color = Colors.white,
  });

  @override
  List<Object> get props =>
      [display, exiting, children, childrenHeight, fullscreen, color];
}

class BottomModalSheetState extends BottomModalSheetCubitState {
  const BottomModalSheetState({
    required super.display,
    required super.exiting,
    required super.children,
    super.childrenHeight,
    super.fullscreen,
    super.color,
  });
}
