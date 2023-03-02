/// currently we use the built in showModalBottomSheet here, but this could be
/// replaced with a custom implementation since we don't really need this layer
/// to perform a showModalBottomSheet action. still it serves as a good example
/// for things such as a tutorial layer or a custom dialog.
///
/// Note: this solution (specifically using `.addPostFrameCallback` with
/// `showModalBottomSheet`) is not ideal since it doesn't really work well on
/// windows since it spews errors in the logs. we see no such errors on android.
/// ios untested.

import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/widgets/front_curve.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/bottom/modal/cubit.dart';

class BottomModalSheetWidget extends StatelessWidget {
  const BottomModalSheetWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<BottomModalSheetCubit, BottomModalSheetCubitState>(
        builder: (context, bottomModalSheetState) {
          if (bottomModalSheetState.display) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Scrim(),
                FrontCurve(
                    color: Colors.white,
                    fuzzyTop: false,
                    height: 200,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Row(children: const [Text('data')]),
                        Row(children: const [Text('data')]),
                        Row(children: const [Text('data')]),
                      ],
                    )),
              ],
            );
          }
          return SizedBox.shrink();
        },
      );
}

class Scrim extends StatelessWidget {
  const Scrim({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () => context.read<BottomModalSheetCubit>().hide(),
      child: Container(
          height: double.infinity,
          width: double.infinity,
          color: AppColors.scrim));
}
