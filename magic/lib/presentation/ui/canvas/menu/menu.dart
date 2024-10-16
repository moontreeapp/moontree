import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/presentation/ui/canvas/menu/page.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/animations/fading.dart';

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
