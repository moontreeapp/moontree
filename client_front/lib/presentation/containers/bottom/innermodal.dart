/// currently we use the built in showModalBottomSheet here, but this could be
/// replaced with a custom implementation since we don't really need this layer
/// to perform a showModalBottomSheet action. still it serves as a good example
/// for things such as a tutorial layer or a custom dialog.
///
/// Note: this solution (specifically using `.addPostFrameCallback` with
/// `showModalBottomSheet`) is not ideal since it doesn't really work well on
/// windows since it spews errors in the logs. we see no such errors on android.
/// ios untested.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/bottom/modal/cubit.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

class InnerBottomModalSheetWidget extends StatefulWidget {
  const InnerBottomModalSheetWidget({Key? key}) : super(key: key);

  @override
  _InnerBottomModalSheetWidgetState createState() =>
      _InnerBottomModalSheetWidgetState();
}

class _InnerBottomModalSheetWidgetState
    extends State<InnerBottomModalSheetWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<BottomModalSheetCubit, BottomModalSheetCubitState>(
        builder: (context, bottomModalSheetState) {
          if (bottomModalSheetState.display) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) async {
                await showModalBottomSheet(
                  context: components.routes.routeContext!,
                  builder: (_) => ListView(
                    shrinkWrap: true,
                    children: [
                      Row(children: const [Text('data')]),
                      Row(children: const [Text('data')]),
                      Row(children: const [Text('data')]),
                    ],
                  ),
                ).then((value) => context.read<BottomModalSheetCubit>().hide());
              },
            );
          }
          return SizedBox.shrink();
        },
      );
}
