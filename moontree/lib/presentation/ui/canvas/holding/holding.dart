import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/holding/cubit.dart';
import 'package:moontree/presentation/ui/canvas/holding/page.dart';
import 'package:moontree/presentation/widgets/animations/fading.dart';

class HodingDetail extends StatelessWidget {
  const HodingDetail({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<HoldingCubit, HoldingState>(
      buildWhen: (HoldingState previous, HoldingState current) =>
          previous.active != current.active ||
          (!previous.active && !current.active),
      builder: (context, state) => state.transitionWidgets(state,
          onEntering: const FadeIn(child: HodingDetailPage()),
          onEntered: const HodingDetailPage(), // never triggered
          onExiting: const FadeOut(child: HodingDetailPage()),
          onExited: const SizedBox.shrink()));
}
