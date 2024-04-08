import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/panel/cubit.dart';
import 'package:magic/domain/concepts/side.dart';
import 'package:magic/presentation/widgets/navbar/background.dart';
import 'package:magic/presentation/widgets/animations/sliding.dart';

class PanelPage extends StatelessWidget {
  const PanelPage({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<PanelCubit, PanelState>(
          //buildWhen: (PanelState previous, PanelState current) =>
          //    current.active || !current.active,
          builder: (BuildContext context, PanelState state) {
        if (state.child != null) {
          final DraggableScrollableController draggableScrollController =
              DraggableScrollableController();
          final double minExtent = 0.61;
          final double maxExtent = 1.0;
          // not sure this must be tracked in our system
          //components.cubits.bottomModalSheet
          //        .setHeight(minExtent * screen.app.height);
          return DraggableScrollableSheet(
              controller: draggableScrollController,
              expand: false,
              initialChildSize: minExtent,
              minChildSize: minExtent,
              maxChildSize: maxExtent,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                //draggableScrollController.addListener(() async => components
                //    .cubits.bottomModalSheet
                //    .setHeight(draggableScrollController.pixels));

                late final Widget child;
                if (state.prior?.child != null &&
                    state.transition != Side.none) {
                  final prior = state.prior!.child!(scrollController);
                  final current = state.child!(scrollController);
                  child = Stack(children: [
                    SlideSide(
                      enter: false,
                      side: state.transition.opposite,
                      child: prior,
                    ),
                    SlideSide(
                      enter: true,
                      side: state.transition,
                      child: current,
                    ),
                  ]);
                } else {
                  child = state.child!(scrollController);
                }

                return NavbarBackground(
                    color: Colors.black,
                    //height: screen.app.height -
                    //    (topPosition ?? screen.app.height * 0.5),
                    //blurAmount: widget.blurAmount,
                    //imageFilter: widget.imageFilter,
                    child: child);
              });
        }
        return const SizedBox.shrink();
      });
}

/** moontree impl.
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
                ((state.children.length - 1) * state.childrenHeight + 16) /
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
*/