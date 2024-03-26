import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/cubits/pane/cubit.dart';
import 'package:moontree/cubits/wallet/feed/cubit.dart';
import 'package:moontree/domain/concepts/side.dart';
import 'package:moontree/presentation/ui/wallet/feed/feed.dart';
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
      buildWhen: (PaneState previous, PaneState current) =>
          current.active || !current.active,
      builder: (BuildContext context, PaneState state) {
        if (state.active) {
          return const SlideSide(
            enter: true,
            side: Side.bottom,
            child: DraggablePane(),
          );
        }
        if (!state.active) {
          return const SlideSide(
            enter: false,
            side: Side.bottom,
            child: DraggablePane(),
          );
        }
        return const DraggablePane();
      });
}

class DraggablePane extends StatelessWidget {
  final Color color;
  final double height;
  final Widget? child;
  const DraggablePane({
    super.key,
    this.color = Colors.white,
    this.height = 0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaneCubit, PaneState>(
        buildWhen: (PaneState previous, PaneState current) =>
            current.active &&
            (previous.initial != current.initial ||
                previous.min != current.min ||
                previous.max != current.max),
        builder: (BuildContext context, PaneState state) {
//if (state.scrollableChild != null) {}
//        // if we have a height change, move it to the correct height,
//        if (state.prior?.child != null && state.child == null) {
//          print('pane 2');
//          return PaneBackground(
//              height: state.height,
//              child: FadeOut(
//                child: state.prior!.child!,
//              ));
//        }
//        if (state.prior?.child == null && state.child != null) {
//          print('pane 3');
//          return PaneBackground(
//              height: state.height,
//              child: FadeIn(
//                child: state.child!,
//              ));
//        }
//        print('pane 4');
//        return PaneBackground(height: state.height, child: state.child);
          // not sure this must be tracked in our system
          //components.cubits.bottomModalSheet
          //        .setHeight(minExtent * screen.app.height);

          return DraggableScrollableSheet(
              controller: state.controller,
              expand: false,
              initialChildSize: state.initial,
              minChildSize: state.min,
              maxChildSize: state.max,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                //draggableScrollController.addListener(() async => components
                //    .cubits.bottomModalSheet
                //    .setHeight(draggableScrollController.pixels));
                //late final Widget child;
                //if (state.prior?.scrollableChild != null &&
                //    state.transition != Side.none) {
                //  final prior = state.prior!.scrollableChild!(scrollController);
                //  final current = state.scrollableChild!(scrollController);
                //  child = Stack(children: [
                //    SlideSide(
                //      enter: false,
                //      side: state.transition.opposite,
                //      child: prior,
                //    ),
                //    SlideSide(
                //      enter: true,
                //      side: state.transition,
                //      child: current,
                //    ),
                //  ]);
                //} else {
                //  child = state.scrollableChild!(scrollController);
                //}
                //print('pane 1');
                //return DraggablePaneBackground(child: FadeIn(child: child));
                return DraggablePaneBackground(
                    child:
                        DraggablePaneStack(scrollController: scrollController));
              });
        });
  }
}

class DraggablePaneStack extends StatelessWidget {
  final ScrollController scrollController;
  const DraggablePaneStack({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) => Stack(children: [
        //WalletFeedLayer(scrollController: scrollController),
        EmptyFeed(scrollController: scrollController),
      ]);
}

class EmptyFeed extends StatelessWidget {
  final ScrollController scrollController;
  const EmptyFeed({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) => BlocBuilder<PaneCubit, PaneState>(
      buildWhen: (previous, current) => previous.height != current.height,
      builder: (BuildContext context, PaneState state) {
        Future<void> setHeightTo({
          double? heightAsPercent,
          double? heightInPixels,
          bool reset = true,
        }) async {
          assert(heightAsPercent != null || heightInPixels != null);
          heightAsPercent = heightAsPercent ?? heightInPixels! / screen.height;
          if (state.controller.isAttached) {
            state.controller.animateTo(
              heightAsPercent,
              duration: slideDuration,
              curve: Curves.easeInOutCirc,
            );
            await Future.delayed(slideDuration);
          }
          if (reset) {
            cubits.pane.update(height: -1);
          }
        }

        if (state.height == -1) {
          const SizedBox.shrink();
        }
        WidgetsBinding.instance.addPostFrameCallback((_) async =>
            await setHeightTo(heightInPixels: state.height, reset: true));
        return ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            itemCount: 100,
            itemBuilder: (context, index) =>
                ListTile(title: Text('default $index')));
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
  final Widget? child;
  const DraggablePaneBackground({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: screen.width,
        height: screen.displayHeight,
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(bottom: screen.navbar.height),
        decoration: BoxDecoration(
          color: Colors.white,
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
