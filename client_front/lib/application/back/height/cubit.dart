// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:client_front/application/utilities.dart';
import 'package:client_front/presentation/services/services.dart' as services;

part 'state.dart';

class BackContainerHeightCubit extends Cubit<BackContainerHeightCubitState>
    with HeightCubitMixin {
  BackContainerHeightCubit()
      : super(BackContainerHeightState(
            height: services.screen.backPageContainer.maxHeight));

  @override
  void max() => emit(BackContainerHeightState(
      height: services.screen.backPageContainer.maxHeight));

  @override
  void mid() => emit(BackContainerHeightState(
      height: services.screen.backPageContainer.midHeight));

  @override
  void hidden() => emit(BackContainerHeightState(
      height: services.screen.backPageContainer.hiddenHeight));
}
