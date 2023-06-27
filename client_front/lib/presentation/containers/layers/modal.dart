import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/layers/modal/bottom/cubit.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/widgets/front_curve.dart';
import 'package:client_front/presentation/widgets/other/sliding.dart';
import 'package:client_front/presentation/widgets/other/fading.dart';
import 'package:client_front/presentation/services/services.dart' show screen;
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/components/shadows.dart' as shadows;

class BottomModalSheet extends StatelessWidget {
  const BottomModalSheet({Key? key}) : super(key: key);

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
            final double minExtent =
                min(childrenPixels, screen.frontContainer.midHeightPercentage);
            final double maxExtent = min(1.0, max(minExtent, childrenPixels));
            if (!state.exiting) {
              components.cubits.bottomModalSheet
                  .setHeight(minExtent * screen.app.height);
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  FadeIn(child: Scrim()),
                  SlideUp(
                      heightPercentage: 1,
                      child: DraggableScrollableSheet(
                          controller: draggableScrollController,
                          expand: false,
                          initialChildSize: state.fullscreen ? 1 : minExtent,
                          minChildSize: minExtent,
                          maxChildSize: state.fullscreen ? 1 : maxExtent,
                          builder: (BuildContext context,
                              ScrollController scrollController) {
                            draggableScrollController.addListener(() async =>
                                components.cubits.bottomModalSheet.setHeight(
                                    draggableScrollController.pixels));
                            return FrontCurve(
                                color: state.color,
                                frontLayerBoxShadow:
                                    state.color == Colors.transparent
                                        ? []
                                        : shadows.frontLayer,
                                fuzzyTop: false,
                                child: ListView(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
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
                          padding: EdgeInsets.zero,
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
