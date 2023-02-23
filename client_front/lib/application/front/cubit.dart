// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:client_front/application/utilities.dart';
import 'package:client_front/presentation/services/services.dart' as services;

part 'state.dart';

class FrontContainerCubit extends Cubit<FrontContainerCubitState>
    with HeightCubitMixin {
  FrontContainerCubit()
      : super(FrontContainerState(
            height: services.screen.frontContainer.maxHeight));

  void setHidden(bool hide) =>
      emit(FrontContainerState(height: state.height, hide: hide));

  void setHeightToExactly({required double height}) => emit(FrontContainerState(
      height: math.max(services.screen.frontContainer.minHeight,
          math.min(height, services.screen.frontContainer.maxHeight)),
      hide: state.hide));

  @override
  void max() async => emit(FrontContainerState(
      height: services.screen.frontContainer.maxHeight, hide: state.hide));

  @override
  void mid() async => emit(FrontContainerState(
      height: services.screen.frontContainer.midHeight, hide: state.hide));

  @override
  void min() async => emit(FrontContainerState(
      height: services.screen.frontContainer.minHeight, hide: state.hide));

  @override
  void hidden() async => emit(FrontContainerState(
      height: services.screen.frontContainer.hiddenHeight, hide: state.hide));
}
