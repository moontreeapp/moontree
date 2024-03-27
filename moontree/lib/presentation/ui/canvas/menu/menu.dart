import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/menu/cubit.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<MenuCubit, MenuState>(
          builder: (BuildContext context, MenuState state) {
        if (state.wasInactive && state.active) {
          return GestureDetector(
              onTap: () => print('go into submenu by changing menu cubit'),
              child: const Center(
                  child:
                      Text('Menu...', style: TextStyle(color: Colors.grey))));
        }
        if (state.wasActive && !state.active) {
          return const SizedBox.shrink();
        }
        if (state.wasActive && state.active) {
          return GestureDetector(
              onTap: () =>
                  print('go into or out of submenu by changing menu cubit'),
              child: const Center(
                  child:
                      Text('Menu...', style: TextStyle(color: Colors.grey))));
        }
        return const SizedBox.shrink();
      });
}
