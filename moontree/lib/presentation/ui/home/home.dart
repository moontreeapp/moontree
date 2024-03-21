import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/wallet/cubit.dart';
import 'package:moontree/presentation/ui/home/feed/feed.dart';
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
            if (state.prior?.active == null && state.active) {
              return FadeIn(child: WalletSplit());
            }
            if ((state.prior?.active == null || !state.prior!.active) &&
                !state.active) {
              return const SizedBox.shrink();
            }

            /// REMOVING TRANSITIONS
            //if (!state.prior!.active && state.active) {
            //  return SlideSide(
            //    enter: true,
            //    side: Side.left,
            //    child: WalletSplit(),
            //  );
            //}
            //if (state.prior!.active && !state.active) {
            //  return SlideSide(
            //    enter: false,
            //    side: Side.left,
            //    child: WalletSplit(),
            //  );
            //}
            ////if (state.prior!.active && state.active)
            return WalletSplit();
          });
}

class WalletSplit extends StatelessWidget {
  const WalletSplit({super.key});

  @override
  Widget build(BuildContext context) => Container(
      height: screen.app.displayHeight,
      alignment: Alignment.topCenter,
      color: Colors.black,
      child: Stack(children: [
        WalletFeedLayer(),
      ]));
}
