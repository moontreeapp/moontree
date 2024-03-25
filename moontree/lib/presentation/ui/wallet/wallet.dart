import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/cubits/wallet/cubit.dart';
import 'package:moontree/presentation/ui/wallet/feed/feed.dart';
import 'package:moontree/presentation/ui/wallet/feed/page.dart';
import 'package:moontree/services/services.dart' show screen;
import 'package:moontree/presentation/widgets/animations/fading.dart';

class WalletLayer extends StatelessWidget {
  const WalletLayer({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<WalletLayerCubit, WalletLayerState>(
          buildWhen: (WalletLayerState previous, WalletLayerState current) =>
              previous.active != current.active ||
              (!previous.active && !current.active),
          builder: (context, state) {
            print('WalletLayerCubit: ${state.active}');
            if (state.prior?.active == null && state.active) {
              print('wallet 1');
              cubits.pane.update(child: const WalletFeedPage());
              return const FadeIn(child: WalletLayers());
            }
            if ((state.prior?.active == null || !state.prior!.active) &&
                !state.active) {
              print('wallet 2');
              cubits.pane.removeChildren();
              return const SizedBox.shrink();
            }
            if ((state.prior?.active == true) && !state.active) {
              print('wallet 3');
              cubits.pane.removeChildren();
              return const FadeOut(child: WalletLayers());
            }

            /// REMOVING TRANSITIONS
            //if (!state.prior!.active && state.active) {
            //  return SlideSide(
            //    enter: true,
            //    side: Side.left,
            //    child: WalletLayers(),
            //  );
            //}
            //if (state.prior!.active && !state.active) {
            //  return SlideSide(
            //    enter: false,
            //    side: Side.left,
            //    child: WalletLayers(),
            //  );
            //}
            ////if (state.prior!.active && state.active)
            print('wallet 4');
            cubits.pane.update(child: const WalletFeedPage());
            return const WalletLayers();
          });
}

class WalletLayers extends StatelessWidget {
  const WalletLayers({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
      height: screen.displayHeight,
      child: const Stack(alignment: Alignment.topCenter, children: [
        //WalletFeedLayer(),
      ]));
}
