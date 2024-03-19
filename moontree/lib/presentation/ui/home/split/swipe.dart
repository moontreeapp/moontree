import 'package:flutter/material.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:moontree/domain/common/video.dart';
import 'package:moontree/presentation/components/icons.dart';
import 'package:moontree/presentation/services/services.dart';
import 'package:moontree/presentation/theme/extensions.dart';
import 'package:moontree/presentation/widgets/video/video.dart';

class SwipableVideoHome extends StatelessWidget {
  final bool top;
  final SwipableVideo video;
  const SwipableVideoHome({super.key, required this.video, this.top = true});

  @override
  Widget build(BuildContext context) =>
      SwipableVideoContainer(top: top, video: video);
}

class SwipableVideoContainer extends StatelessWidget {
  final bool top;
  final SwipableVideo video;
  const SwipableVideoContainer(
      {super.key, required this.video, this.top = true});

  @override
  Widget build(BuildContext context) => Stack(children: [
        Container(
          height: screen.app.displayHeight / 2,
          width: screen.width,
          child: BigVideoContainer(
            rounded: false,
            video: video,
          ),
        ),
        VideoOverlay(top: top, video: video),
      ]);
}

class VideoOverlay extends StatelessWidget {
  final bool top;
  final SwipableVideo video;
  const VideoOverlay({super.key, required this.video, this.top = true});

  @override
  Widget build(BuildContext context) => Container(
        height: screen.app.displayHeight / 2,
        width: screen.width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: screen.app.displayHeight / 2,
              width: screen.width / 2,
              padding: EdgeInsets.only(left: 10, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (video.uid == '0') Volume(),
                  Views(video: video),
                  Award(video: video),
                ],
              ),
            ),
            Container(
              height: screen.app.displayHeight / 2,
              width: screen.width / 2,
              padding:
                  EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment:
                    top ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: [
                  HypyrIcons.svgPicture(
                    loc: HypyrIcons.shareHomeLoc,
                    height: 30,
                    width: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class Views extends StatelessWidget {
  final SwipableVideo video;
  const Views({super.key, required this.video});

  @override
  Widget build(BuildContext context) => Container(
      height: 45,
      width: 50,
      child: Column(children: [
        Icon(Hicons.show_bold, size: 24, color: Colors.white38),
        Text('240k',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .caption1!
                .copyWith(color: Colors.white38, fontWeight: FontWeight.w900))
      ]));
}

class Award extends StatelessWidget {
  final SwipableVideo video;
  const Award({super.key, required this.video});

  @override
  Widget build(BuildContext context) => Container(
      height: 45,
      width: 50,
      child: Column(children: [
        Icon(Hicons.award_2_bold, size: 24, color: Colors.white38),
        Text('Month',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .caption1!
                .copyWith(color: Colors.white38, fontWeight: FontWeight.w900))
      ]));
}

class Volume extends StatelessWidget {
  const Volume({super.key});

  @override
  Widget build(BuildContext context) => Container(
        height: 38,
        width: 50,
        alignment: Alignment.center,
        child: Icon(Hicons.volume_high_bold, size: 24, color: Colors.white38),
      );
}
