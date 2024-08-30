import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/services/services.dart';

class WalletChooser extends StatelessWidget {
  const WalletChooser({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<MenuCubit, MenuState>(
      buildWhen: (MenuState previous, MenuState current) =>
          previous.mode != current.mode,
      builder: (BuildContext context, MenuState state) => Padding(
            padding: EdgeInsets.only(
                top: 4,
                bottom: 4,
                left: screen.width * 0.309,
                right: screen.width * 0.309),
            child: true //state.mode == DifficultyMode.easy
                ? const SizedBox(height: 32)
                : Container(
                    height: 32,
                    padding: const EdgeInsets.only(left: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(100)),
                    child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primary700),
                          Flexible(
                              child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('Wallet',
                                      style: TextStyle(
                                          color: AppColors.primary700,
                                          height: 0)))),
                          SizedBox(width: 20),
                        ])),
          ));
}
