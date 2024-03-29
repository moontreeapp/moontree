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
            containerHeight: FrontContainerHeight.max,
            height: services.screen.frontContainer.maxHeight));

  void setHidden(bool hide) {
    print('setHIDDEN!!!');
    emit(FrontContainerState(
      containerHeight: hide ? FrontContainerHeight.hidden : null,
      height: state.height,
      hide: hide,
    ));
  }

  void setHeightToExactly({required double height}) => emit(FrontContainerState(
      containerHeight: null,
      height: math.max(services.screen.frontContainer.minHeight,
          math.min(height, services.screen.frontContainer.maxHeight)),
      hide: state.hide));

  void menuToggle() {
    switch (state.containerHeight) {
      case FrontContainerHeight.min:
        return max();
      default:
        return min();
    }
  }

  void openMenu() => min();
  void closeMenu() => max();

  @override
  void max() async => emit(FrontContainerState(
      containerHeight: FrontContainerHeight.max,
      height: services.screen.frontContainer.maxHeight,
      hide: state.hide));

  @override
  void mid() async => emit(FrontContainerState(
      containerHeight: FrontContainerHeight.mid,
      height: services.screen.frontContainer.midHeight,
      hide: state.hide));

  @override
  void min() async => emit(FrontContainerState(
      containerHeight: FrontContainerHeight.min,
      height: services.screen.frontContainer.minHeight,
      hide: state.hide));

  @override
  void hidden() async => emit(FrontContainerState(
      containerHeight: FrontContainerHeight.hidden,
      height: services.screen.frontContainer.hiddenHeight,
      hide: state.hide));
}
