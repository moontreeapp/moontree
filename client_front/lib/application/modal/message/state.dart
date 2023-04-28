part of 'cubit.dart';

abstract class MessageModalCubitState extends Equatable {
  final Map<String, VoidCallback> behaviors;
  final String? title;
  final String? content;
  final Widget? child;
  const MessageModalCubitState({
    required this.behaviors,
    this.title,
    this.content,
    this.child,
  });

  @override
  List<Object?> get props => [
        behaviors,
        title,
        content,
        child,
      ];
}

class MessageModalState extends MessageModalCubitState {
  const MessageModalState({
    required super.behaviors,
    super.title,
    super.content,
    super.child,
  });
}
