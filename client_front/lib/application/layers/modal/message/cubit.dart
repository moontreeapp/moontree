import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'state.dart';

class MessageModalCubit extends Cubit<MessageModalCubitState> {
  MessageModalCubit() : super(const MessageModalState(behaviors: {}));

  void update({
    Map<String, VoidCallback>? behaviors,
    String? title,
    String? content,
    Widget? child,
  }) =>
      emit(MessageModalState(
        behaviors: behaviors ?? state.behaviors,
        title: title ?? state.title,
        content: content ?? state.content,
        child: child ?? state.child,
      ));

  void reset() => emit(MessageModalState(behaviors: {}));
}
