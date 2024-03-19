import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/cubits/home/feed/cubit.dart';
import 'package:moontree/presentation/layers/home/feed/page.dart';

class HomeFeedLayer extends StatelessWidget {
  const HomeFeedLayer({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<HomeFeedCubit, HomeFeedState>(
          builder: (BuildContext context, HomeFeedState state) {
        return
            //cubits.homeFeed.
            state.videos.isEmpty
                ? GestureDetector(
                    onTap: () {
                      cubits.homeFeed.populateVideos();
                      print('tapped');
                    },
                    child: const Center(child: Text('Tap to populate videos')))
                : HomeFeedPage();
        //);
      });
}
