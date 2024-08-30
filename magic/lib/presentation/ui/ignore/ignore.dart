import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/ignore/cubit.dart';
import 'package:magic/services/services.dart' show screen;

class IgnoreLayer extends StatelessWidget {
  const IgnoreLayer({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<IgnoreCubit, IgnoreState>(
      buildWhen: (IgnoreState previous, IgnoreState current) =>
          previous.active != current.active,
      builder: (BuildContext context, IgnoreState state) {
        if (state.active) {
          return GestureDetector(
              // ignore: avoid_print
              onTap: () => print('ignore tap'),
              onLongPressUp: () => cubits.ignore.update(active: false),
              child: Container(
                padding: const EdgeInsets.all(4.0),
                color: Colors.transparent,
                height: screen.height,
                width: screen.width,
              ));
        }
        return const SizedBox.shrink();
      });
}
