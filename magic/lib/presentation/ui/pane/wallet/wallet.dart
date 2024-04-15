import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/pane/wallet/cubit.dart';
import 'package:magic/presentation/ui/pane/wallet/page.dart';
import 'package:magic/presentation/utils/animation.dart';

class Wallet extends StatelessWidget {
  const Wallet({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<WalletCubit, WalletState>(
      builder: (BuildContext context, WalletState state) =>
          state.transitionFunctions(state,
              onEntering: () {
                //WidgetsBinding.instance.addPostFrameCallback(
                //    (_) => cubits.pane.update(height: screen.pane.midHeight));
                if (state.assets.isEmpty) {
                  return GestureDetector(
                      onTap: cubits.wallet.populateAssets,
                      child: const Center(
                          child: Text('Loading...',
                              style: TextStyle(color: Colors.grey))));
                }
                const child = WalletPage();
                cubits.wallet.update(child: child);
                return child;
              },
              onEntered: () => state.child,
              onExiting: () {
                WidgetsBinding.instance.addPostFrameCallback(
                    (_) => Future.delayed(fadeDuration, () {
                          cubits.wallet.update(active: false);
                          cubits.balance.update(initialized: true);
                        }));
                //return const FadeOut(child: WalletPage());
                return state.child;
              },
              onExited: () {
                const child = SizedBox.shrink();
                cubits.wallet.update(child: child);
                return child;
              }));
}
