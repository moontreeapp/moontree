part of 'cubit.dart';

enum ToastShowType {
  /// fade in, wait duration, fade out
  normal,

  /// show immedaitely, fade out
  fadeAway,
}

class ToastMessage with EquatableMixin {
  final String title;
  final String text;
  final Duration? duration;
  final bool force;

  const ToastMessage({
    this.title = '',
    this.text = '',
    this.duration,
    this.force = false,
  });

  @override
  List<Object?> get props => [title, text];
}

class ToastState with EquatableMixin {
  final VoidCallback? onTap;
  final ToastMessage? msg;
  final double? height;
  final Duration duration;
  final ToastShowType showType;

  const ToastState({
    this.onTap,
    this.msg,
    this.height,
    this.duration = const Duration(seconds: 5),
    this.showType = ToastShowType.normal,
  });

  @override
  List<Object?> get props => [
        onTap,
        msg,
        height,
        duration,
        duration,
        showType,
      ];
}
