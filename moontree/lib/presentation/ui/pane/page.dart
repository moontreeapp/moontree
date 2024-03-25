import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/pane/cubit.dart';
import 'package:moontree/domain/concepts/side.dart';
import 'package:moontree/presentation/utils/animation.dart';
import 'package:moontree/presentation/widgets/animations/fading.dart';
import 'package:moontree/presentation/widgets/animations/sliding.dart';
//import 'package:moontree/domain/concepts/side.dart';
//import 'package:moontree/presentation/widgets/animations/sliding.dart';
import 'package:moontree/services/services.dart';

class PanePage extends StatelessWidget {
  const PanePage({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<PaneCubit, PaneState>(
          //buildWhen: (PaneState previous, PaneState current) =>
          //    current.active || !current.active,
          builder: (BuildContext context, PaneState state) {
        //if (state.prior?.active == true && !state.active) {
        //  return SlideSide(
        //              enter: false,
        //              side: Side.bottom,
        //              child: state.prior?.child ,
        //            );
        //}
        if (!state.active) {
          print('pane 0');
          return const SizedBox.shrink();
        }
        if (state.scrollableChild != null) {
          final DraggableScrollableController draggableScrollController =
              DraggableScrollableController();
          const double minExtent = 0.6181;
          const double maxExtent = 1.0;
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
                if (state.prior?.scrollableChild != null &&
                    state.transition != Side.none) {
                  final prior = state.prior!.scrollableChild!(scrollController);
                  final current = state.scrollableChild!(scrollController);
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
                  child = state.scrollableChild!(scrollController);
                }
                print('pane 1');
                return DraggablePaneBackground(child: FadeIn(child: child));
              });
        }
        // if we have a height change, move it to the correct height,
        if (state.prior?.child != null && state.child == null) {
          print('pane 2');
          return PaneBackground(
              height: state.height,
              child: FadeOut(
                child: state.prior!.child!,
              ));
        }
        if (state.prior?.child == null && state.child != null) {
          print('pane 3');
          return PaneBackground(
              height: state.height,
              child: FadeIn(
                child: state.child!,
              ));
        }
        print('pane 4');
        return PaneBackground(height: state.height, child: state.child);
      });
}

class PaneBackground extends StatelessWidget {
  final Color color;
  final double height;
  final Widget? child;
  const PaneBackground({
    super.key,
    this.color = Colors.white,
    this.height = 0,
    this.child,
  });

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          AnimatedPositioned(
            duration: slideDuration,
            curve: Curves.easeInOutCirc,
            top: screen.height - height,
            left: 0,
            right: 0,
            height: screen.displayHeight + 1, // gets rid of line at bottom
            child: Container(
              width: screen.width,
              height: screen.displayHeight,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: child ?? const SizedBox.shrink(),
            ),
            //child ?? const SizedBox.shrink(),
          ),
        ],
      );
}

class DraggablePaneBackground extends StatelessWidget {
  final Color color;
  final double height;
  final Widget? child;
  const DraggablePaneBackground({
    super.key,
    this.color = Colors.white,
    this.height = 0,
    this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: screen.width,
        height: screen.displayHeight,
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(bottom: screen.navbar.height),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child ?? const SizedBox.shrink(),
      );
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