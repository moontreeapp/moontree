part of 'cubit.dart';

class IgnoreState with EquatableMixin {
  final bool active;

  const IgnoreState({
    this.active = false,
  });

  @override
  List<Object?> get props => [
        active,
      ];
}
