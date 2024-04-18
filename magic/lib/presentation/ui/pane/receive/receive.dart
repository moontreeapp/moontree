import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/pane/receive/cubit.dart';
import 'package:magic/presentation/ui/pane/receive/page.dart';

class Receive extends StatelessWidget {
  const Receive({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<ReceiveCubit, ReceiveState>(
      builder: (BuildContext context, ReceiveState state) =>
          state.transitionWidgets(state,
              onEntering: const ReceivePage(),
              onEntered: const ReceivePage(),
              onExiting: const SizedBox.shrink(),
              onExited: const SizedBox.shrink()));
}
