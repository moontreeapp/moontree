import 'package:flutter/material.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/domain/common/video.dart';
import 'package:moontree/presentation/widgets/animations/swipe.dart';

class SwipableVideoHome extends StatelessWidget {
  final SwipableVideo video;
  const SwipableVideoHome({super.key, required this.video});

  @override
  Widget build(BuildContext context) => SwipableVideoContainer(
        video: video,
        getPreviousVideo: cubits.homeFeed.getPreviousVideo,
        getNextVideo: cubits.homeFeed.getNextVideo,
        onTap: cubits.homeFeed.hide,
      );
}
