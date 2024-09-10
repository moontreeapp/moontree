import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/menu/cubit.dart';
import 'package:magic/presentation/ui/canvas/menu/menu.dart';
// import 'package:magic/presentation/ui/canvas/menu/menu.dart';
// Import your menu components here

class MenuLayer extends StatelessWidget {
  const MenuLayer({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<MenuCubit, MenuState>(
      buildWhen: (MenuState previous, MenuState current) =>
          previous.active != current.active ||
          (!previous.active && !current.active),
      builder: (context, state) {
        return const MenuStack();
      });
}

class MenuStack extends StatelessWidget {
  const MenuStack({super.key});

  @override
  Widget build(BuildContext context) => const Stack(
        alignment: Alignment.topCenter,
        children: [Menu()],
      );
}
