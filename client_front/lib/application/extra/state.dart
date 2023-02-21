part of 'cubit.dart';

@immutable
class ExtraContainerState {
  final Widget child;

  const ExtraContainerState({required this.child});

  @override
  String toString() => 'ExtraContainer(child=$child)';

  List<Object?> get props => <Object?>[child];

  factory ExtraContainerState.initial() =>
      const ExtraContainerState(child: SizedBox.shrink());

  ExtraContainerState load({Widget? child}) =>
      ExtraContainerState.load(state: this, child: child);

  factory ExtraContainerState.load({
    required ExtraContainerState state,
    Widget? child,
  }) =>
      ExtraContainerState(child: child ?? state.child);
}
