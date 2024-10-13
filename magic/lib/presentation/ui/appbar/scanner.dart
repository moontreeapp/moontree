import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/pane/wallet/cubit.dart';
//import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/ui/welcome/pair_with_chrome.dart';
import 'package:magic/presentation/widgets/animations/fading.dart';
import 'package:magic/services/services.dart';

class Scanner extends StatelessWidget {
  const Scanner({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<WalletCubit, WalletState>(
      buildWhen: (WalletState previous, WalletState current) =>
          previous.active != current.active,
      builder: (context, state) {
        if (state.active) return const FadeIn(child: ScannerButton());
        return const FadeOut(child: ScannerButton());
      });
}

class ScannerButton extends StatelessWidget {
  const ScannerButton({super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () =>
          //cubits.toast.flash(
          //        msg: const ToastMessage(
          //      title: 'Pair with Extension',
          //      text: '(coming soon)',
          //    )),
          cubits.welcome
              .update(active: true, child: const PairWithChromePage()),
      child: Container(
        height: 16 + screen.iconMedium + 16,
        width: 24 + screen.iconMedium,
        alignment: Alignment.centerLeft,
        color: Colors.transparent,
        child: Icon(Icons.qr_code_scanner_rounded,
            color: AppColors.white67, size: screen.iconMedium),
      ));
}
