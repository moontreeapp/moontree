// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:client_front/application/utilities.dart';
import 'package:client_front/presentation/services/services.dart' as services;

part 'state.dart';

class BackContainerCubit extends Cubit<BackContainerCubitState>
    with HeightCubitMixin {
  BackContainerCubit()
      : super(BackContainerState(
            height: services.screen.backContainer.maxHeight,
            child: SizedBox.shrink()));

  void update({double? height, Widget? child}) => emit(BackContainerState(
      height: height ?? state.height, child: child ?? state.child));

  @override
  void max() => emit(BackContainerState(
      height: services.screen.backContainer.maxHeight, child: state.child));

  @override
  void mid() => emit(BackContainerState(
      height: services.screen.backContainer.midHeight, child: state.child));

  @override
  void hidden() => emit(BackContainerState(
      height: services.screen.backContainer.hiddenHeight, child: state.child));
}
