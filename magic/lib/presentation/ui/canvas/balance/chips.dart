import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/presentation/theme/colors.dart';

class Chips extends StatelessWidget {
  const Chips({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<MenuCubit, MenuState>(
      buildWhen: (MenuState previous, MenuState current) =>
          previous.mode != current.mode,
      builder: (BuildContext context, MenuState state) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                height: 26,
                decoration: BoxDecoration(
                    //color: AppColors.white87,
                    border: Border.all(color: AppColors.white87, width: 1),
                    borderRadius: BorderRadius.circular(100)),
                child: const Text('chips',
                    style: TextStyle(color: AppColors.white87, height: 0))),
          ));
}
