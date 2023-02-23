import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'state.dart';

class LoginCubit extends Cubit<LoginCubitState> {
  LoginCubit() : super(const LoginState(isConsented: false));

  void update({bool? isConsented}) => emit(LoginState(
        isConsented: isConsented ?? state.isConsented,
      ));

  void reset() => emit(LoginState(
        isConsented: false,
      ));
}
