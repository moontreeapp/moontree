import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/cubits/pane/wallet/cubit.dart';
import 'package:moontree/presentation/ui/pane/wallet/page.dart';
import 'package:moontree/presentation/utils/animation.dart';
import 'package:moontree/presentation/widgets/animations/fading.dart';
import 'package:moontree/services/services.dart';

class Wallet extends StatelessWidget {
  const Wallet({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<WalletCubit, WalletState>(
      builder: (BuildContext context, WalletState state) =>
          state.transitionFunctions(state,
              onEntering: () {
                //WidgetsBinding.instance.addPostFrameCallback(
                //    (_) => cubits.pane.update(height: screen.pane.midHeight));
                if (state.currency.isEmpty && state.assets.isEmpty) {
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
                WidgetsBinding.instance.addPostFrameCallback((_) =>
                    Future.delayed(fadeDuration,
                        () => cubits.wallet.update(active: false)));
                //return const FadeOut(child: WalletPage());
                return state.child;
              },
              onExited: () {
                const child = SizedBox.shrink();
                cubits.wallet.update(child: child);
                return child;
              }));
}
