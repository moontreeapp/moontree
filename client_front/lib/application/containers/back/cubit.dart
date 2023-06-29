// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:client_front/application/utilities.dart';
import 'package:client_front/presentation/services/services.dart' as services;
import 'package:client_front/presentation/components/components.dart'
    as components;

part 'state.dart';

class BackContainerCubit extends Cubit<BackContainerCubitState>
    with HeightCubitMixin {
  BackContainerCubit()
      : super(BackContainerState(
          height: services.screen.backContainer.maxHeight,
          path: '/',
          priorPath: '/',
        ));

  bool get menuExpanded => state.menuExpanded;

  void previousMenu() {
    if (menuExpanded) {
      final x = state.path.split('/');
      emit(BackContainerState(
        height: state.height,
        path: x.sublist(0, x.length - 1).join('/'),
        priorPath: state.path,
      ));
      components.cubits.title.refresh();
    }
  }

  void update({double? height, String? path}) {
    emit(BackContainerState(
      height: height ?? state.height,
      path: path ?? state.path,
      priorPath: path == state.path ? state.priorPath : state.path,
    ));
    if (['/menu', '/menu/settings'].contains(path)) {
      components.cubits.title.refresh();
    }
  }

  @override
  void max() => emit(BackContainerState(
        height: services.screen.backContainer.maxHeight,
        path: state.path,
        priorPath: state.priorPath,
      ));

  @override
  void mid() => emit(BackContainerState(
        height: services.screen.backContainer.midHeight,
        path: state.path,
        priorPath: state.priorPath,
      ));

  @override
  void hidden() => emit(BackContainerState(
        height: services.screen.backContainer.hiddenHeight,
        path: state.path,
        priorPath: state.priorPath,
      ));
}
