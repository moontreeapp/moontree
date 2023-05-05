import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_back/streams/streams.dart';
import 'package:client_front/domain/utils/auth.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

part 'state.dart';

class LoginCubit extends Cubit<LoginCubitState> {
  LoginCubit() : super(const LoginState(isConsented: false)) {
    setupListener();
  }

  /// we can notify logout process from anywhere using this listener
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  void setupListener() =>
      listeners.add(streams.app.auth.logout.listen((bool value) {
        if (value && !components.cubits.location.state.loggedOut) {
          logout();
        }
      }));

  void update({bool? isConsented}) => emit(LoginState(
        isConsented: isConsented ?? state.isConsented,
      ));

  void reset() => emit(LoginState(
        isConsented: false,
      ));
}
