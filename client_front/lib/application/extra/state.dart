part of 'cubit.dart';

@immutable
class ContentExtraState {
  final Widget child;

  const ContentExtraState({required this.child});

  @override
  String toString() => 'ContentExtra(child=$child)';

  List<Object?> get props => <Object?>[child];

  factory ContentExtraState.initial() =>
      const ContentExtraState(child: SizedBox.shrink());

  ContentExtraState load({Widget? child}) =>
      ContentExtraState.load(state: this, child: child);

  factory ContentExtraState.load({
    required ContentExtraState state,
    Widget? child,
  }) =>
      ContentExtraState(child: child ?? state.child);
}
