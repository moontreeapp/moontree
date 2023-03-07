import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/bottom/modal/cubit.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/widgets/front_curve.dart';
import 'package:client_front/presentation/widgets/other/sliding.dart';
import 'package:client_front/presentation/widgets/other/fading.dart';
import 'package:client_front/presentation/services/services.dart' show screen;
import 'package:client_front/presentation/components/components.dart'
    as components;

class BottomModalSheetWidget extends StatelessWidget {
  const BottomModalSheetWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<BottomModalSheetCubit, BottomModalSheetCubitState>(
        builder: (context, state) {
          if (state.display) {
            final DraggableScrollableController draggableScrollController =
                DraggableScrollableController();
            final double childrenPixels =
                (state.children.length * state.childrenHeight + 16) /
                    screen.app.height;
            final double minExtent = min(childrenPixels, 0.5);
            final double maxExtent = min(1.0, max(minExtent, childrenPixels));
            if (!state.exiting) {
              components.cubits.bottomModalSheet
                  .setHeight(minExtent * screen.app.height);
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  FadeIn(child: Scrim()),
                  SlideUp(
                      child: DraggableScrollableSheet(
                          controller: draggableScrollController,
                          expand: false,
                          initialChildSize: minExtent,
                          minChildSize: minExtent,
                          maxChildSize: maxExtent,
                          builder: (BuildContext context,
                              ScrollController scrollController) {
                            draggableScrollController.addListener(() async =>
                                components.cubits.bottomModalSheet.setHeight(
                                    draggableScrollController.pixels));
                            return FrontCurve(
                                color: Colors.white,
                                fuzzyTop: false,
                                child: ListView(
                                  shrinkWrap: true,
                                  controller: scrollController,
                                  children: state.children,
                                ));
                          })),
                ],
              );
            }
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                FadeIn(enter: false, child: IgnorePointer(child: Scrim())),
                SlideUp(
                    enter: false,
                    child: FrontCurve(
                        color: Colors.white,
                        fuzzyTop: false,
                        height: components.cubits.bottomModalSheet.height,
                        child: ListView(
                          shrinkWrap: true,
                          children: state.children,
                        ))),
              ],
            );
          }
          return SizedBox.shrink();
        },
      );
}

class Scrim extends StatelessWidget {
  const Scrim({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () => context.read<BottomModalSheetCubit>().hide(),
      child: Container(
          height: double.infinity,
          width: double.infinity,
          color: AppColors.scrim));
}
