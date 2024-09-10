import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/app/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/presentation/ui/login/native.dart';

class LockLayer extends StatelessWidget {
  const LockLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (AppState previous, AppState current) =>
          previous.status != current.status,
      builder: (BuildContext context, AppState state) {
        if (state.prior?.status == AppLifecycleState.inactive &&
            state.status == AppLifecycleState.resumed &&
            cubits.app.isAuthenticated) {
          cubits.welcome.update(
              active: true, child: const LoginNative(child: SizedBox.shrink()));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
