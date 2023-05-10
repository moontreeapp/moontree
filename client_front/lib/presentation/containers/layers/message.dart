import 'package:client_front/application/layers/modal/message/cubit.dart';
import 'package:client_front/presentation/widgets/other/fading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/presentation/utils/animation.dart';
import 'package:client_front/presentation/widgets/front_curve.dart'
    show FrontCurve;
import 'package:client_front/presentation/components/shapes.dart' as shapes;
import 'package:client_front/presentation/theme/theme.dart';

class MessageModalLayer extends StatefulWidget {
  const MessageModalLayer({Key? key}) : super(key: key);

  @override
  MessageModalLayerState createState() => MessageModalLayerState();
}

class MessageModalLayerState extends State<MessageModalLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late MessageModalCubit cubit;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: slideDuration,
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MessageModalCubit, MessageModalCubitState>(
          //bloc: cubit..enter(),
          builder: (BuildContext context, MessageModalCubitState state) {
        if (state.title != null ||
            state.content != null ||
            state.child != null) {
          return FadeIn(
              child: GestureDetector(
                  /* for testing - remove onTap later */
                  //onTap: cubit.hide,
                  behavior: HitTestBehavior.opaque,
                  child: FrontCurve(
                      fuzzyTop: false,
                      frontLayerBoxShadow: const <BoxShadow>[],
                      color: const Color(0xFF000000)
                          .withOpacity(1 - .38), // AppColors.white87,,
                      child: AlertDialog(
                          elevation: 0,
                          shape: shapes.rounded8,
                          title: state.title == null
                              ? null
                              : Text(state.title!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium),
                          content: state.child != null && state.content != null
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                (24 - 24 - 40 - 40),
                                        child: Text(state.content!,
                                            overflow: TextOverflow.fade,
                                            softWrap: true,
                                            maxLines: 10,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: AppColors.black38))),
                                    state.child!,
                                  ],
                                )
                              : state.child ??
                                  (state.content != null
                                      ? SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              (24 - 24 - 40 - 40),
                                          child: Text(state.content!,
                                              overflow: TextOverflow.fade,
                                              softWrap: true,
                                              maxLines: 10,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color:
                                                          AppColors.black38)))
                                      : null),
                          actions: <Widget>[
                            for (String key in state.behaviors.keys)
                              TextButton(
                                  onPressed: state.behaviors[key],
                                  child: Text(key,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                              fontWeight: FontWeights.semiBold,
                                              color: AppColors.primary)))
                          ]))));
        }
        return SizedBox.shrink();
      });
}
