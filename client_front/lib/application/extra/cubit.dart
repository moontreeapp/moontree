import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
part 'state.dart';

class ContentExtraCubit extends Cubit<ContentExtraState> {
  String? priorPage;

  ContentExtraCubit() : super(ContentExtraState.initial());

  void reset() => emit(ContentExtraState.initial());

  void enter() => emit(state);

  void set({Widget? child}) => emit(state.load(child: child));
}
