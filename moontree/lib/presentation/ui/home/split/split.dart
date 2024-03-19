import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/cubits/home/feed/cubit.dart';
import 'package:moontree/presentation/layers/home/split/page.dart';

class HomeSplitLayer extends StatelessWidget {
  const HomeSplitLayer({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<HomeFeedCubit, HomeFeedState>(
          buildWhen: (HomeFeedState previous, HomeFeedState current) =>
              previous.videos.isEmpty != current.videos.isEmpty,
          builder: (BuildContext context, HomeFeedState state) {
            if (state.videos.isEmpty) {
              return GestureDetector(
                  onTap: () {
                    cubits.homeFeed.populateVideos();
                    print('tapped');
                  },
                  child: const Center(
                      child: Text('\n\n\n\n\nTap to populate videos',
                          style: TextStyle(color: Colors.white))));
            } else {
              //if (state.prior?.champion == state.champion &&
              //    state.prior?.challenger != state.challenger) {
              //  // bottom animation
              //} else if (state.prior?.champion != state.champion &&
              //    state.prior?.challenger != state.challenger) {
              //  // top animation
              //}
              return HomeSplitPage();
            }

            /*
        
        If I click on a Challenger then the Challenger and the champion change. 
        If I click on the champion only the Challenger changes. So we'll look at
        that simpler case first:

        I click on the champion. A plus one bubbles up from the person's head, 
        and a circle goes around their face I guess I don't know. The circle is
        only ever on the left side. But when it's brand new challenge and you
        haven't decided who's better I guess there's no Circle. What else 
        happens? The bottom video which is the Challenger Fades away and get
        smaller. And it fades into black. While a new video slides in, probably
        from the right. It could also slide in from the bottom. Then it starts
        playing. the profile picture of the challenger is going to fade in over
        the existing one.

        If I click the Challenger instead all of that is going to happen except
        something is going to happen before that occurs: the top video is going
        to fade to black just like the bottom video did. Then the bottom video
        is going to slide up. While that's happening the Challenger face is
        going to replace the champion face, it's just going to fade in over it
        simple easy no big deal. then the other animation will play.


        */
          });
}
