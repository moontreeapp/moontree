import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/extra/cubit.dart';
import 'package:client_front/application/front/cubit.dart';
import 'package:client_front/presentation/services/services.dart' as services;
import 'package:client_front/presentation/utils/animation.dart' as animation;
import 'package:client_front/presentation/widgets/front_curve.dart';

class WalletHolding extends StatelessWidget {
  const WalletHolding({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('Holding');

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class FrontHoldingExtra extends StatefulWidget {
  const FrontHoldingExtra({Key? key}) : super(key: key);

  @override
  FrontHoldingExtraState createState() => FrontHoldingExtraState();
}

class FrontHoldingExtraState extends State<FrontHoldingExtra>
    with TickerProviderStateMixin {
  final DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();
  final double minSize = services.screen.frontContainer.midHeightPercentage;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late FrontContainerCubit heightCubit;
  double draggableHeight = services.screen.frontContainer.midHeightPercentage;

  @override
  void initState() {
    super.initState();
    heightCubit = BlocProvider.of<FrontContainerCubit>(context);
    heightCubit.setHidden(true);
    draggableScrollableController.addListener(scrollListener);
    _controller = AnimationController(
      vsync: this,
      duration: animation.fadeDuration,
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    draggableScrollableController.removeListener(scrollListener);
    draggableScrollableController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void scrollListener() => heightCubit.setHeightToExactly(
      height: services.screen.frontContainer.maxHeight *
          draggableScrollableController.size);

  @override
  Widget build(BuildContext context) => Container(
      color: Colors.transparent,
      height: services.screen.frontContainer.maxHeight,
      width: MediaQuery.of(context).size.width,
      child: DraggableScrollableSheet(
          initialChildSize: minSize,
          minChildSize: minSize,
          maxChildSize: 1,
          controller: draggableScrollableController,
          builder: (BuildContext context, ScrollController scrollController) =>
              FrontCurve(
                  color: Colors.white,
                  fuzzyTop: true,
                  child: BlocBuilder<ExtraContainerCubit, ExtraContainerState>(
                      //bloc: cubit..enter(),
                      builder: (BuildContext context,
                              ExtraContainerState state) =>
                          AnimatedContainer(
                              duration: animation.fadeDuration,
                              curve: Curves.easeInOut,
                              alignment: Alignment.center,
                              child: FadeTransition(
                                  opacity: _opacityAnimation,
                                  child: ListView.builder(
                                      controller: scrollController,
                                      itemCount: 100,
                                      itemBuilder: (BuildContext context,
                                              int index) =>
                                          ListTile(
                                              title:
                                                  Text('Item $index')))))))));
}
