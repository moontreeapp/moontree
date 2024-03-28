import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/menu/cubit.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<MenuCubit, MenuState>(
      builder: (BuildContext context, MenuState state) => state.transitionWidgets(
          state,
          onEntering: GestureDetector(
              onTap: () => print('go into submenu by changing menu cubit'),
              child: const Center(
                  child:
                      Text('Menu...', style: TextStyle(color: Colors.grey)))),
          onEntered: GestureDetector(
              onTap: () =>
                  print('go into or out of submenu by changing menu cubit'),
              child: const Center(
                  child:
                      Text('Menu...', style: TextStyle(color: Colors.grey)))),
          onExiting: const SizedBox.shrink(),
          onExited: const SizedBox.shrink()));
}
