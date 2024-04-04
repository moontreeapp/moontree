import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/pane/send/cubit.dart';
import 'package:moontree/presentation/ui/pane/send/page.dart';

class Send extends StatelessWidget {
  const Send({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<SendCubit, SendState>(
      builder: (BuildContext context, SendState state) =>
          state.transitionWidgets(state,
              onEntering: const SendPage(),
              onEntered: const SendPage(),
              onExiting: const SizedBox.shrink(),
              onExited: const SizedBox.shrink()));
}
