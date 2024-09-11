import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/app/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/presentation/ui/login/native.dart';
import 'package:magic/utils/log.dart';
import 'package:moontree_utils/moontree_utils.dart';

class LockLayer extends StatelessWidget {
  const LockLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (AppState previous, AppState current) =>
          previous.status != current.status,
      builder: (BuildContext context, AppState state) {
        see(state.wasPaused, state.status, LogColor.magenta);
        if (state.wasPaused &&
            state.status == AppLifecycleState.resumed &&
            !cubits.app.isAuthenticated) {
          see('authenticating');
          cubits.app.update(wasPaused: false);
          cubits.welcome.update(
              active: true,
              child: LoginNative(
                  child: const SizedBox.shrink(),
                  onThen: () => cubits.welcome.update(active: false)));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
