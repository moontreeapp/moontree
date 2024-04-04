import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/canvas/menu/cubit.dart';
import 'package:moontree/presentation/ui/canvas/menu/page.dart';
import 'package:moontree/presentation/utils/animation.dart';
import 'package:moontree/presentation/widgets/animations/fading.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<MenuCubit, MenuState>(
      builder: (BuildContext context, MenuState state) =>
          state.transitionWidgets(state,
              onEntering: const FadeIn(delay: fadeDuration, child: MenuPage()),
              onEntered: const MenuPage(), // never triggered
              onExiting: const FadeOut(child: MenuPage()),
              onExited: const SizedBox.shrink()));
}
