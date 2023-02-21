import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/extra/cubit.dart';
import 'package:client_front/application/front/cubit.dart';
import 'package:client_front/presentation/services/services.dart' as services;
import 'package:client_front/presentation/utilities/animation.dart'
    as animation;
import 'package:client_front/presentation/widgets/front_curve.dart';

class FrontHoldingScreen extends StatefulWidget {
  const FrontHoldingScreen({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('frontHolding');

  @override
  FrontHoldingScreenState createState() => FrontHoldingScreenState();
}

class FrontHoldingScreenState extends State<FrontHoldingScreen>
    with SingleTickerProviderStateMixin {
  late ContentExtraCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of<ContentExtraCubit>(context);
    cubit.set(child: const FrontHoldingExtra());
  }

  @override
  void dispose() {
    cubit.reset();
    super.dispose();
  }

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
  final double minSize = services.screen.frontPageContainer.midHeightPercentage;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late FrontContainerCubit heightCubit;
  double draggableHeight =
      services.screen.frontPageContainer.midHeightPercentage;

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
      height: services.screen.frontPageContainer.maxHeight *
          draggableScrollableController.size);

  @override
  Widget build(BuildContext context) => Container(
      color: Colors.transparent,
      height: services.screen.frontPageContainer.maxHeight,
      width: MediaQuery.of(context).size.width,
      child: DraggableScrollableSheet(
          initialChildSize: minSize,
          minChildSize: minSize,
          maxChildSize: 1,
          controller: draggableScrollableController,
          builder: (BuildContext context, ScrollController scrollController) =>
              FrontCurve(
                  child: BlocBuilder<ContentExtraCubit, ContentExtraState>(
                      //bloc: cubit..enter(),
                      builder: (BuildContext context,
                              ContentExtraState state) =>
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
