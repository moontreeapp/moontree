// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:client_front/application/utilities.dart';
import 'package:client_front/presentation/services/services.dart' as services;

part 'state.dart';

class FrontContainerHeightCubit extends Cubit<FrontContainerHeightCubitState>
    with HeightCubitMixin {
  FrontContainerHeightCubit()
      : super(FrontContainerHeightState(
            height: services.screen.frontPageContainer.maxHeight));

  void setHidden(bool hide) =>
      emit(FrontContainerHeightState(height: state.height, hide: hide));

  void setHeightToExactly({required double height}) =>
      emit(FrontContainerHeightState(
          height: math.max(services.screen.frontPageContainer.minHeight,
              math.min(height, services.screen.frontPageContainer.maxHeight)),
          hide: state.hide));

  @override
  void max() async => emit(FrontContainerHeightState(
      height: services.screen.frontPageContainer.maxHeight, hide: state.hide));

  @override
  void mid() async => emit(FrontContainerHeightState(
      height: services.screen.frontPageContainer.midHeight, hide: state.hide));

  @override
  void min() async => emit(FrontContainerHeightState(
      height: services.screen.frontPageContainer.minHeight, hide: state.hide));

  @override
  void hidden() async => emit(FrontContainerHeightState(
      height: services.screen.frontPageContainer.hiddenHeight,
      hide: state.hide));
}
