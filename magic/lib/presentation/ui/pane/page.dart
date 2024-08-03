import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/fade/cubit.dart';
import 'package:magic/cubits/pane/cubit.dart';
import 'package:magic/domain/concepts/side.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/ui/pane/receive/receive.dart';
import 'package:magic/presentation/ui/pane/send/send.dart';
import 'package:magic/presentation/ui/pane/transaction/transaction.dart';
import 'package:magic/presentation/ui/pane/transactions/transactions.dart';
import 'package:magic/presentation/ui/pane/wallet/wallet.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/animations/sliding.dart';
//import 'package:magic/domain/concepts/side.dart';
//import 'package:magic/presentation/widgets/animations/sliding.dart';
import 'package:magic/services/services.dart';

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
    this.color = AppColors.foreground,
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

          return NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification) {
                  final double snapTo = [
                    screen.pane.maxHeight,
                    screen.pane.midHeight,
                    screen.pane.minHeight,
                  ].reduce((a, b) => (cubits.pane.height - a).abs() <
                          (cubits.pane.height - b).abs()
                      ? a
                      : b);
                  cubits.pane.snapTo(snapTo);
                  return false;
                }
                return false;
              },
              child: DraggableScrollableSheet(
                  controller: draggableScrollController,
                  expand: false,
                  initialChildSize: state.initial,
                  minChildSize: state.min,
                  maxChildSize: state.max,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    cubits.pane.update(controller: draggableScrollController);
                    cubits.pane.update(scroller: scrollController);
                    return const DraggablePaneBackground(
                        child: DraggablePaneStack());
                  }));
        });
  }
}

class DraggablePaneStack extends StatelessWidget {
  const DraggablePaneStack({super.key});

  @override
  Widget build(BuildContext context) => const Stack(children: [
        Wallet(),
        Transactions(),
        Transaction(),
        Send(),
        Receive(),
        EmptyFeed(),
        FadeLayer(),
      ]);
}

class EmptyFeed extends StatelessWidget {
  const EmptyFeed({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<PaneCubit, PaneState>(
      buildWhen: (previous, current) =>
          previous.height != current.height || current.dispose,
      builder: (BuildContext context, PaneState state) {
        final ScrollController scroller = state.scroller!;
        double pixelsToPercentage(double pixels) => pixels / screen.height;
        Future<void> setHeightTo({
          double? heightAsPercent,
          double? heightInPixels,
          bool reset = true,
        }) async {
          assert(heightAsPercent != null || heightInPixels != null);
          heightAsPercent =
              heightAsPercent ?? pixelsToPercentage(heightInPixels!);
          if (state.controller.isAttached) {
            state.controller.animateTo(
              heightAsPercent,
              duration: quickSlideDuration,
              curve: Curves.easeInOutCirc,
            );
            await Future.delayed(slideDuration);
          }
          if (reset) {
            cubits.pane.dispose();
          }
        }

        if (state.dispose) {
          return const SizedBox.shrink();
        }
        if (state.controller.isAttached) {
          WidgetsBinding.instance.addPostFrameCallback((_) async =>
              await setHeightTo(heightInPixels: state.height, reset: false));
          //state.controller.jumpTo(0);
          return const SizedBox.shrink();
        }
        WidgetsBinding.instance.addPostFrameCallback((_) async =>
            await setHeightTo(heightInPixels: state.height, reset: true));
        return ListView.builder(
            controller: scroller,
            shrinkWrap: true,
            itemCount: 0,
            itemBuilder: (context, index) => ListTile(
                    title: Text(
                  'default $index',
                  style: const TextStyle(color: Colors.black),
                )));
      });
}

class PaneBackground extends StatelessWidget {
  final Color color;
  final double height;
  final Widget? child;
  const PaneBackground({
    super.key,
    this.color = AppColors.foreground,
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
        //padding: EdgeInsets.only(bottom: screen.navbar.height),
        decoration: const BoxDecoration(
          color: AppColors.foreground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          //boxShadow: [
          //  BoxShadow(
          //    color: Colors.black.withOpacity(0.2),
          //    spreadRadius: 5,
          //    blurRadius: 7,
          //    offset: const Offset(0, 3),
          //  ),
          //],
        ),
        child: child ?? const SizedBox.shrink(),
      );
}

class FadeLayer extends StatelessWidget {
  const FadeLayer({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<FadeCubit, FadeState>(
      buildWhen: (previous, current) => previous.fade != current.fade,
      builder: (context, FadeState state) => IgnorePointer(
          //ignoring: false, // weird. this acts like ignoring == true
          ignoring: true,
          child: AnimatedOpacity(
              opacity: state.fade.opacity,
              duration: fadeDuration,
              child: const DraggablePaneBackground())));
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
                        color: AppColors.foreground,
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
