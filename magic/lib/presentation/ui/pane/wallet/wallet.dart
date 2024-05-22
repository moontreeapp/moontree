import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/pane/wallet/cubit.dart';
import 'package:magic/presentation/ui/pane/wallet/page.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/services/services.dart';

class Wallet extends StatelessWidget {
  const Wallet({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<WalletCubit, WalletState>(
      builder: (BuildContext context, WalletState state) =>
          state.transitionFunctions(state,
              onEntering: () {
                //WidgetsBinding.instance.addPostFrameCallback(
                //    (_) => cubits.pane.update(height: screen.pane.midHeight));
                if (state.holdings.isEmpty) {
                  return GestureDetector(
                      onTap: cubits.wallet.populateAssets,
                      child: const Center(
                          child: Text('Loading...',
                              style: TextStyle(color: Colors.grey))));
                }
                return const WalletStack(child: WalletPage());
              },
              onEntered: () => const WalletStack(child: WalletPage()),
              onExiting: () {
                WidgetsBinding.instance.addPostFrameCallback(
                    (_) => Future.delayed(fadeDuration, () {
                          cubits.wallet.update(active: false);
                          cubits.balance.update(initialized: true);
                        }));
                //return const FadeOut(child: WalletPage());
                return WalletStack(child: state.child);
              },
              onExited: () {
                return const WalletStack(child: SizedBox.shrink());
              }));
}

class WalletStack extends StatelessWidget {
  final Widget child;
  const WalletStack({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.bottomCenter,
        children: [
          child,
          GestureDetector(
            onTap: () => cubits.pane.snapTo(screen.pane.midHeight),
            onVerticalDragStart: (details) =>
                cubits.pane.snapTo(screen.pane.midHeight),
            child: Container(
                height: 56, width: screen.width, color: Colors.transparent),
          )
        ],
      );
}
