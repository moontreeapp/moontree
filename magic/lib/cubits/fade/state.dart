part of 'cubit.dart';

enum FadeEvent {
  fadeIn,
  fadeOut,
  faded,
  none;

  double get opacity {
    switch (this) {
      case FadeEvent.fadeIn:
        return 0;
      case FadeEvent.fadeOut:
        return 1;
      case FadeEvent.faded:
        return 1;
      case FadeEvent.none:
        return 0;
      default:
        return 0;
    }
  }
}

class FadeState with EquatableMixin {
  final FadeEvent fade;

  const FadeState({
    this.fade = FadeEvent.none,
  });

  @override
  List<Object?> get props => [
        fade,
      ];
}
