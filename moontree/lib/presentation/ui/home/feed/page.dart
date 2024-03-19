import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubits.dart';
import 'package:moontree/presentation/layers/home/feed/swipe.dart';

class HomeFeedPage extends StatelessWidget {
  const HomeFeedPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<HomeFeedCubit, HomeFeedState>(
          builder: (BuildContext context, HomeFeedState state) =>
              SwipableVideoHome(video: state.champion));
}
