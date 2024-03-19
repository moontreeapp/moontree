import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/cubits/cubits.dart';
import 'package:moontree/domain/common/video.dart';
import 'package:moontree/presentation/layers/home/split/swipe.dart';
import 'package:moontree/presentation/widgets/animations/animations.dart';

class HomeSplitPage extends StatelessWidget {
  const HomeSplitPage({super.key});

  @override
  Widget build(BuildContext context) => Column(children: [
        ChampionVideo(),
        ChallengerVideo(),
      ]);
}

class ChampionVideo extends StatelessWidget {
  const ChampionVideo({super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () => cubits.homeFeed.update(
              challenger: cubits.homeFeed.getNextVideo(
            cubits.homeFeed.state.challenger,
          )),
      child: BlocBuilder<HomeFeedCubit, HomeFeedState>(
          buildWhen: (HomeFeedState previous, HomeFeedState current) =>
              previous.champion.uid != current.champion.uid,
          builder: (BuildContext context, HomeFeedState state) {
            if (state.prior?.champion != null &&
                state.prior?.champion != '' &&
                state.prior?.champion != const SwipableVideo.none() &&
                state.prior?.champion != state.champion) {
              return Stack(children: [
                //SlideSide(
                //    side: Side.right,
                //    enter: false,
                //    duration: Duration(milliseconds: 500),
                //    child:
                FadeOut(
                    refade: true,
                    //away: true,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    child: SwipableVideoHome(
                        top: true, video: state.prior!.champion)),
                //),
                //SlideSide(
                //    side: Side.left,
                //    //side: Side.right,
                //    duration: Duration(milliseconds: 500),
                //    child: SwipableVideoHome(video: state.champion))
                FadeIn(
                    refade: true,
                    delay: Duration(milliseconds: 500),
                    duration: Duration(milliseconds: 500),
                    child: SwipableVideoHome(video: state.champion))
              ]);
            }
            return SwipableVideoHome(top: true, video: state.champion);
          }));
}

class ChallengerVideo extends StatelessWidget {
  const ChallengerVideo({super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () => cubits.homeFeed.update(
              champion: cubits.homeFeed.getNextVideo(
            cubits.homeFeed.state.champion,
          )),
      child: BlocBuilder<HomeFeedCubit, HomeFeedState>(
          buildWhen: (HomeFeedState previous, HomeFeedState current) =>
              previous.challenger.uid != current.challenger.uid,
          builder: (BuildContext context, HomeFeedState state) {
            if (state.prior?.challenger != null &&
                state.prior?.challenger != '' &&
                state.prior?.challenger != const SwipableVideo.none() &&
                state.prior?.challenger != state.challenger) {
              return Stack(children: [
                //SlideSide(
                //    side: Side.right,
                //    enter: false,
                //    duration: Duration(milliseconds: 500),
                //    child:
                FadeOut(
                    refade: true,
                    //away: true,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    child: SwipableVideoHome(
                        top: false, video: state.prior!.challenger)), //),
                FadeIn(
                    refade: true,
                    delay: Duration(milliseconds: 500),
                    duration: Duration(milliseconds: 500),
                    child:
                        SwipableVideoHome(top: false, video: state.challenger))
                //SlideSide(
                //  side: Side.left,
                //  duration: Duration(milliseconds: 500),
                //  child:
                //      SwipableVideoHome(top: false, video: state.challenger))
              ]);
            }
            return const SizedBox.shrink();
            //return SwipableVideoHome(video: state.challenger);
          }));
}
