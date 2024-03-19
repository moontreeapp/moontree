import 'package:flutter/material.dart';
import 'package:moontree/domain/common/video.dart';
import 'package:moontree/presentation/widgets/video/video.dart';
import 'package:moontree/services/services.dart' show screen;
import 'package:moontree/presentation/widgets/animations/sliding.dart';

enum SwipeDirection {
  none,
  up,
  down,
  left,
  right;

  // A + Start
  bool get isNone => this == SwipeDirection.none;
  bool get isUp => this == SwipeDirection.up;
  bool get isDown => this == SwipeDirection.down;
  bool get isLeft => this == SwipeDirection.left;
  bool get isRight => this == SwipeDirection.right;
}

enum SwipeAxis {
  none,
  x,
  y;

  bool get isNone => this == SwipeAxis.none;
  bool get isX => this == SwipeAxis.x;
  bool get isHorizontal => this == SwipeAxis.x;
  bool get isY => this == SwipeAxis.y;
  bool get isVertical => this == SwipeAxis.y;
}

class SwipableVideoContainer extends StatefulWidget {
  final SwipableVideo video;
  final SwipableVideo Function(SwipableVideo) getNextVideo;
  final SwipableVideo Function(SwipableVideo) getPreviousVideo;
  final VoidCallback onTap;
  const SwipableVideoContainer({
    super.key,
    required this.video,
    required this.getNextVideo,
    required this.getPreviousVideo,
    required this.onTap,
  });

  @override
  _SwipableVideoContainerState createState() => _SwipableVideoContainerState();
}

class _SwipableVideoContainerState extends State<SwipableVideoContainer> {
  late SwipableVideo video;
  late SwipableVideo previousVideo;
  late SwipableVideo nextVideo;
  SwipeDirection direction = SwipeDirection.none;
  SwipeAxis axis = SwipeAxis.none;
  final double thresholdY = 0.10;
  final double thresholdX = 0.10;
  double startY = 0.0;
  double endY = 0.0;
  double startX = 0.0;
  double endX = 0.0;
  double lastY = 0.0;
  double lastX = 0.0;

  @override
  void initState() {
    super.initState();
    video = widget.video;
    setVideos();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updatePercentY(double y) => setState(() => endY = y);
  void updatePercentX(double x) => setState(() => endX = x);
  bool swippedDown() => asPercentHeight(endY - startY) > thresholdY;
  bool swippedUp() => asPercentHeight(startY - endY) > thresholdY;
  bool swippedRight() => asPercentWidth(endX - startX) > thresholdX;
  bool swippedLeft() => asPercentWidth(startX - endX) > thresholdX;
  double asPercentHeight(double y) => y / screen.app.height;
  double asPercentWidth(double x) => x / screen.width;

  void setSwipe() {
    if (swippedDown()) {
      direction = SwipeDirection.down;
    } else if (swippedUp()) {
      direction = SwipeDirection.up;
    } else if (swippedRight()) {
      direction = SwipeDirection.right;
    } else if (swippedLeft()) {
      direction = SwipeDirection.left;
    }
  }

  void resetSwipe() {
    direction = SwipeDirection.none;
  }

  void resetY() {
    lastY = endY - startY;
    startY = 0.0;
    endY = 0.0;
  }

  void resetX() {
    lastX = endX - startX;
    startX = 0.0;
    endX = 0.0;
  }

  void cycle() {
    setState(() {
      setVideos();
      resetSwipe();
      resetY();
      resetX();
    });
  }

  void setVideos() {
    if (direction.isDown) {
      nextVideo = video;
      video = previousVideo;
      previousVideo = widget.getPreviousVideo(video);
    } else if (direction.isUp) {
      previousVideo = video;
      video = nextVideo;
      nextVideo = widget.getNextVideo(video);
    } else if (direction.isRight) {
      nextVideo = video;
      video = previousVideo;
      previousVideo = widget.getPreviousVideo(video);
    } else if (direction.isLeft) {
      previousVideo = video;
      video = nextVideo;
      nextVideo = widget.getNextVideo(video);
    } else if (direction.isNone) {
      previousVideo = widget.getPreviousVideo(video);
      nextVideo = widget.getNextVideo(video);
    }
  }

  Widget getVerticalWidget() {
    // checking "endY > 0 &&" prevents glitch on drag start
    if (endY > 0 && endY > startY) {
      return Positioned(
        top: (endY - startY) - screen.app.displayHeight,
        // can be a still image of first frame.
        child: Container(
          height: screen.app.displayHeight,
          width: screen.width,
          child: BigVideoContainer(
            rounded: false,
            video: previousVideo,
          ),
        ),
      );
    }
    if (endY > 0 && endY < startY) {
      return Positioned(
        bottom: (startY - endY) - screen.app.displayHeight,
        child: Container(
          height: screen.app.displayHeight,
          width: screen.width,
          child: BigVideoContainer(
            rounded: false,
            video: nextVideo,
          ),
        ),
      );
    }
    if (endY == startY && lastY > 0 && direction.isDown) {
      return SlideTo(
        startTop: lastY - screen.app.displayHeight,
        endTop: 0,
        onEnd: cycle,
        curve: Curves.easeOut,
        child: Container(
          height: screen.app.displayHeight,
          width: screen.width,
          child: BigVideoContainer(
            rounded: false,
            video: previousVideo,
          ),
        ),
      );
    }
    if (endY == startY && lastY > 0) {
      return SlideTo(
        startTop: lastY - screen.app.displayHeight,
        endTop: -screen.app.displayHeight,
        child: Container(
          height: screen.app.displayHeight,
          width: screen.width,
          child: BigVideoContainer(
            rounded: false,
            video: previousVideo,
          ),
        ),
      );
    }
    if (endY == startY && lastY < 0 && direction.isUp) {
      return SlideTo(
        startBottom: -lastY - screen.app.displayHeight,
        endBottom: 0,
        onEnd: cycle,
        curve: Curves.easeOut,
        child: Container(
          height: screen.app.displayHeight,
          width: screen.width,
          child: BigVideoContainer(
            rounded: false,
            video: nextVideo,
          ),
        ),
      );
    }
    if (endY == startY && lastY < 0) {
      return SlideTo(
        startBottom: -lastY - screen.app.displayHeight,
        endBottom: -screen.app.displayHeight,
        child: Container(
          height: screen.app.displayHeight,
          width: screen.width,
          child: BigVideoContainer(
            rounded: false,
            video: nextVideo,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget getHorizontalWidget() {
    // checking "endX > 0 &&" prevents glitch on drag start
    if (endX > 0 && endX > startX) {
      return Positioned(
        left: (endX - startX) - screen.width,
        // can be a still image of first frame.
        child: Container(
          height: screen.app.displayHeight,
          width: screen.width,
          child: BigVideoContainer(
            rounded: false,
            video: previousVideo,
          ),
        ),
      );
    }
    if (endX > 0 && endX < startX) {
      return Positioned(
        right: (startX - endX) - screen.width,
        child: Container(
          height: screen.app.displayHeight,
          width: screen.width,
          child: BigVideoContainer(
            rounded: false,
            video: nextVideo,
          ),
        ),
      );
    }
    if (endX == startX && lastX > 0 && direction.isRight) {
      return SlideTo(
        startLeft: lastX - screen.width,
        endLeft: 0,
        onEnd: cycle,
        curve: Curves.easeOut,
        child: Container(
          height: screen.app.displayHeight,
          width: screen.width,
          child: BigVideoContainer(
            rounded: false,
            video: previousVideo,
          ),
        ),
      );
    }
    if (endX == startX && lastX > 0) {
      return SlideTo(
        startLeft: lastX - screen.width,
        endLeft: -screen.width,
        child: Container(
          height: screen.app.displayHeight,
          width: screen.width,
          child: BigVideoContainer(
            rounded: false,
            video: previousVideo,
          ),
        ),
      );
    }
    if (endX == startX && lastX < 0 && direction.isLeft) {
      return SlideTo(
        startRight: -lastX - screen.width,
        endRight: 0,
        onEnd: cycle,
        curve: Curves.easeOut,
        child: Container(
          height: screen.app.displayHeight,
          width: screen.width,
          child: BigVideoContainer(
            rounded: false,
            video: nextVideo,
          ),
        ),
      );
    }
    if (endX == startX && lastX < 0) {
      return SlideTo(
        startRight: -lastX - screen.width,
        endRight: -screen.width,
        child: Container(
          height: screen.app.displayHeight,
          width: screen.width,
          child: BigVideoContainer(
            rounded: false,
            video: nextVideo,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: widget.onTap,
      // not necessary
      //onVerticalDragDown: (DragDownDetails details) =>
      //   startY = details.localPosition.dy,
      onVerticalDragStart: (DragStartDetails details) {
        resetX();
        axis = SwipeAxis.y;
        startY = details.localPosition.dy;
      },
      onVerticalDragUpdate: (DragUpdateDetails details) =>
          updatePercentY(details.localPosition.dy),
      onVerticalDragEnd: (DragEndDetails details) {
        setSwipe();
        setState(() => resetY());
      },
      onVerticalDragCancel: () {
        setState(() => resetY());
      },
      // not necessary
      //onHorizontalDragDown: (DragDownDetails details) =>
      //    startX = details.localPosition.dx,
      onHorizontalDragStart: (DragStartDetails details) {
        resetY();

        axis = SwipeAxis.x;
        startX = details.localPosition.dx;
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        updatePercentX(details.localPosition.dx);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        setSwipe();
        setState(() => resetX());
      },
      onHorizontalDragCancel: () {
        setState(() => resetX());
      },
      child: Stack(children: [
        Container(
          height: screen.app.displayHeight,
          width: screen.width,
          child: BigVideoContainer(
            rounded: false,
            video: video,
          ),
        ),
        if (axis.isVertical) getVerticalWidget() else getHorizontalWidget(),
      ]));
}
