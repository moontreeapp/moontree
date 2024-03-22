import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/cubits/wallet/transactions/cubit.dart';
import 'package:moontree/presentation/ui/wallet/feed/feed.dart';
import 'package:moontree/services/services.dart' show screen;
import 'package:moontree/presentation/widgets/animations/fading.dart';

class TransactionsLayer extends StatelessWidget {
  const TransactionsLayer({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TransactionsLayerCubit, TransactionsLayerState>(
          buildWhen: (TransactionsLayerState previous,
                  TransactionsLayerState current) =>
              previous.active != current.active ||
              (!previous.active && !current.active),
          builder: (context, state) {
            if (state.prior?.active == null && state.active) {
              return const FadeIn(child: TransactionsLayers());
            }
            if ((state.prior?.active == null || !state.prior!.active) &&
                !state.active) {
              //cubits.walletLayer.update(active: true);
              return const SizedBox.shrink();
            }

            /// REMOVING TRANSITIONS
            //if (!state.prior!.active && state.active) {
            //  return SlideSide(
            //    enter: true,
            //    side: Side.left,
            //    child: TransactionsLayers(),
            //  );
            //}
            //if (state.prior!.active && !state.active) {
            //  return SlideSide(
            //    enter: false,
            //    side: Side.left,
            //    child: TransactionsLayers(),
            //  );
            //}
            ////if (state.prior!.active && state.active)
            return const TransactionsLayers();
          });
}

class TransactionsLayers extends StatelessWidget {
  const TransactionsLayers({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
      height: screen.displayHeight,
      child: const Stack(alignment: Alignment.topCenter, children: [
        WalletFeedLayer(),
      ]));
}
