part of 'cubit.dart';

abstract class LoginCubitState extends Equatable {
  final bool isConsented;

  const LoginCubitState({
    required this.isConsented,
  });

  @override
  List<Object?> get props => [isConsented];
}

class LoginState extends LoginCubitState {
  const LoginState({required bool isConsented})
      : super(isConsented: isConsented);
}
