import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/app/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/presentation/ui/welcome/welcome.dart';
import 'package:magic/utils/log.dart';

class LockLayer extends StatelessWidget {
  const LockLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (AppState previous, AppState current) =>
          previous.status != current.status,
      builder: (BuildContext context, AppState state) {
        see(state.wasPaused, state.status, LogColors.magenta);
        if (state.wasPaused &&
            state.status == AppLifecycleState.resumed &&
            !cubits.app.isAuthenticated) {
          /// show authentication popup - has known issue:
          /// if fails or they cancel, it still lets them in.
          //import 'package:magic/presentation/ui/login/native.dart';
          //import 'package:moontree_utils/moontree_utils.dart';
          //see('authenticating');
          //cubits.app.update(wasPaused: false);
          //cubits.welcome.update(
          //    active: true,
          //    child: LoginNative(
          //        child: const SizedBox.shrink(),
          //        onThen: () => cubits.welcome.update(active: false)));

          /// new design: just clear sensistive info and send to welcome screen:
          cubits.keys.clearAll().then((_) => cubits.keys.loadXPubs()).then(
              (_) => cubits.welcome
                  .update(active: true, child: const WelcomeBackScreen()));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
