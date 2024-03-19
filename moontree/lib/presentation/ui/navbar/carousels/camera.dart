import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';
import 'package:moontree/utils/maths.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/cubits/navbar/cubit.dart';
import 'package:moontree/cubits/navbar/carousels/camera/cubit.dart';
import 'package:moontree/presentation/layers/navbar/stickers.dart';
import 'package:moontree/presentation/widgets/animations/scrolling.dart';
import 'package:moontree/services/services.dart' show screen;
//import 'package:moontree/presentation/widgets/animations/bounce.dart';

class CameraCarousel extends StatelessWidget {
  const CameraCarousel({super.key});

  @override
  Widget build(BuildContext context) => Container(
      width: screen.width,
      height: screen.navbar.midHeight,
      alignment: Alignment.bottomCenter,
      child: CameraNavCarousel());
}

class CameraNavCarousel extends StatefulWidget {
  const CameraNavCarousel({super.key});

  @override
  _CameraNavCarouselState createState() => _CameraNavCarouselState();
}

class _CameraNavCarouselState extends State<CameraNavCarousel> {
  final listScroll = PausableSnapScrollController(initialScrollOffset: 0);
  final paddingListScroll = ScrollController(initialScrollOffset: 0);
  final double initialPosition = 0.0;
  double lastOffset = 0.0;
  final bool reverse = false; // could be a left handed setting.
  bool isInit = true;

  @override
  void initState() {
    super.initState();
    cubits.cameraCarousel.update(scroll: listScroll);
    listScroll.addListener(hapticFeedback);
    paddingListScroll.addListener(syncUp);
    //listScroll.addListener(() {
    //  if (listScroll.position.activity.velocity.pixelsPerSecond.dy > flickVelocityThreshold) {
    //    // The user flicked with high velocity
    //    // Scroll to the end of the list
    //    listScroll.animateTo(
    //      listScroll.position.maxScrollExtent,
    //      duration: Duration(milliseconds: 500), // You can adjust the duration
    //      curve: Curves.easeOut, // You can adjust the curve
    //    );
    //  }
    //});
    listScroll.setIgnoreSnap(false);
    Future.delayed(Duration(milliseconds: 500),
        () => listScroll.jumpTo(listScroll.offset + 1));
  }

  @override
  void dispose() {
    try {
      cubits.cameraCarousel.update(scroll: null, resetScroll: true);
      listScroll.removeListener(hapticFeedback);
      listScroll.dispose();
      paddingListScroll.removeListener(syncUp);
      paddingListScroll.dispose();
    } catch (e) {
      print(e);
    }
    super.dispose();
  }

  void hapticFeedback() {
    //cubits.navbar.update(selectedIndex: -1);
    if (listScroll.offset > lastOffset + 60 ||
        listScroll.offset < lastOffset - 60) {
      lastOffset = listScroll.offset;
      Vibration.vibrate(duration: 10, amplitude: 10);
    }
  }

  void syncDown() {
    paddingListScroll.jumpTo(listScroll.offset);
  }

  void syncUp() {
    if (paddingListScroll.offset != listScroll.offset) {
      listScroll.jumpTo(paddingListScroll.offset);
    }
  }

  int get selectedIndex => cubits.cameraCarousel.state.selectedIndex;

  bool isScrolling(ScrollController controller) =>
      controller.position.isScrollingNotifier.value;

  void clearIndex() {
    if (listScroll.offset > 0 // onReachEnd solves the right side:
        /*&& listScroll.offset < listScroll.position.maxScrollExtent*/) {
      print(listScroll.offset);
      cubits.cameraCarousel.update(selectedIndex: -1);
      listScroll.setIgnoreSnap(false);
    }
  }

  void updateIndex(index) {
    print('onItemFocused $index');
    Vibration.vibrate(duration: 20, amplitude: 20);
    if (cubits.cameraCarousel.state.selectedIndex != index) {
      setState(() {
        /// probably not necessary
        //if (cubits.gallery.state.path != '') {
        //  cubits.gallery.update(path: '');
        //}
        cubits.cameraCarousel.update(selectedIndex: index);
        cubits.navbar.update(
          extendedSelected: index == 0 ? null : ExtendedNavbarItem.none,
        );
      });
    }
  }

  void Function(int, DragEndDetails) onFlick(CameraCarouselState? state) =>
      (int index, DragEndDetails details) async {
        //if (index == state.selectedIndex) {
        if ((details.primaryVelocity ?? 0) < -400) {
          cubits.navbar.max(
            extendedSelected: ExtendedNavbarItem.search,
          );
        }
        //} else {
        //  /// no need to swipe to open
        //  //if ((details.primaryVelocity ?? 0) < -7000) {
        //  // // todo: select correct category, move or still
        //  //  cubits.navbar.max(extendedSelected: (
        //  //   state.selectedIndex == 0
        //  //      ? ExtendedNavbarItem.say
        //  //      : ExtendedNavbarItem.search));
        //  //}
        //}
      };
  void Function(DragEndDetails) onFlickBackground(CameraCarouselState? state) =>
      (DragEndDetails details) async {
        if ((details.primaryVelocity ?? 0) < -400) {
          cubits.navbar.max(
            extendedSelected: ExtendedNavbarItem.search,
          );
        }
      };

  void Function(int) onTapPostFocus(CameraCarouselState state) =>
      (int index) async {
        if (index == state.selectedIndex) {
          //final flickable = cameraButtons[index];
          //final flickableWidget = Container(
          //    alignment: Alignment.topCenter,
          //    height: screen.navbar.carouselHeight,
          //    child: HypyrIcons.pngEmoji(flickable.hexcode));
          cubits.tutorial.flicked();
          // .then( trigger send to endpoint after undo has disappeared )
        }
      };

  final List<Color> cameraButtons = [
    Colors.white,
    Colors.red,
  ];

  @override
  Widget build(BuildContext context) => Container(
      width: screen.width,
      height: screen.navbar.carouselHeight + screen.navbar.carouselPadding,
      alignment: Alignment.bottomCenter,
      child: ClipRect(
          //borderRadius: BorderRadius.circular(30.0), // ClipRRect
          child: ShaderMask(
              shaderCallback: (Rect rect) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Colors.white60,
                    Colors.white60,
                    Colors.white,
                    Colors.white,
                    Colors.white60,
                    Colors.white60,
                    Colors.transparent
                  ],
                  stops: [0.0, 0.08, .28, .37, .63, .72, .92, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Column(children: [
                Container(
                    height: screen.navbar.carouselHeight,
                    width: screen.width,
                    alignment: Alignment.center,
                    child: Stack(alignment: Alignment.center, children: [
                      BlocBuilder<CameraCarouselCubit, CameraCarouselState>(
                          buildWhen: (previous, current) =>
                              previous.selectedIndex != current.selectedIndex,
                          builder: (context, state) {
                            return ScrollSnapList(
                                listController: listScroll,
                                reverse: reverse,
                                sensitivity: 2.5,
                                duration: const Duration(milliseconds: 100),
                                alignment: Alignment.bottomCenter,
                                indicatorAlignment: Alignment.topCenter,
                                indicatorPadding: EdgeInsets.only(top: 4),
                                clipBehavior: Clip.hardEdge,
                                selectedItemAnchor: SelectedItemAnchor.MIDDLE,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: false,
                                dispatchScrollNotifications: false,
                                dynamicItemSize: true,
                                dynamicSizeEquation: (distance) =>
                                    positiveInterpolation(distance, 0.0,
                                        screen.navbar.itemWidth, 1.0, 0.7),
                                indicatorHeight: screen.navbar.carouselHeight,
                                initialIndex: initialPosition,
                                itemSize: screen.navbar.itemWidth,
                                itemCount: cameraButtons.length,
                                onScrollStart: clearIndex,
                                onReachEnd: () => cubits.cameraCarousel.update(
                                    selectedIndex: cameraButtons.length),
                                onLongPressPreFocus: (index) {},
                                onFlick: onFlick(state),
                                onBackgroundFlick: onFlickBackground(state),
                                onTapPostFocus: onTapPostFocus(state),
                                onItemFocus: (_) => syncDown(),
                                onItemFocused: updateIndex,
                                itemBuilder: (buildContext, index) {
                                  return CameraPictureButton(
                                      chosen: state.selectedIndex == index,
                                      color: cameraButtons[index]);
                                });
                          })
                    ])),

                /// why not just make them taller, I think we could now...
                /// no, that's right, it's because of the growing animation.
                Container(
                    height: screen.navbar.carouselPadding,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification notification) {
                        if (notification is ScrollStartNotification) {
                          if (isInit) {
                            isInit = false;
                            listScroll.jumpTo(listScroll.offset + 1);
                          } else {
                            listScroll.setIgnoreSnap(true);
                            syncUp();
                          }
                        } else if (notification is ScrollUpdateNotification) {
                          syncUp();
                        } else if (notification is ScrollEndNotification) {
                          listScroll.setIgnoreSnap(false);
                          syncUp();
                        }
                        return true;
                      },
                      child: ScrollSnapList(
                          listController: paddingListScroll,
                          reverse: reverse,
                          sensitivity: 2.5,
                          shrinkWrap: false,
                          dispatchScrollNotifications: true,
                          clipBehavior: Clip.hardEdge,
                          selectedItemAnchor: SelectedItemAnchor.MIDDLE,
                          scrollDirection: Axis.horizontal,
                          indicatorHeight: screen.navbar.carouselHeight,
                          //initialIndex: initialPosition,
                          itemSize: screen.navbar.itemWidth,
                          onScrollStart: clearIndex,
                          onItemFocus: updateIndex,
                          onItemFocused: updateIndex,
                          onFlick: onFlick(null),
                          onBackgroundFlick: onFlickBackground(null),
                          itemCount: cameraButtons.length + 1 + 1,
                          itemBuilder: (buildContext, index) => Container(
                                width: screen.navbar.itemWidth,
                                height: screen.navbar.itemHeight,
                              )),
                    )),
              ]))));
}
