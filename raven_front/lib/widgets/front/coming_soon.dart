import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/utils/zips.dart';
import 'package:raven_front/widgets/widgets.dart';

class ComingSoonPlaceholder extends StatelessWidget {
  final String message;
  final bool swap;
  final ScrollController scrollController;

  const ComingSoonPlaceholder({
    required this.scrollController,
    this.message = 'Loading...',
    this.swap = false, // different background placeholder
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FrontCurve(
      child: Stack(
        children: [
          ListView(
            controller: scrollController,
            children: [
              for (var _ in range(4))
                swap
                    ? components.empty.swapPlaceholder(context)
                    : components.empty.assetPlaceholder(context)
            ],
          ),
          IgnorePointer(
            child: Container(
              height: MediaQuery.of(context).size.height * .5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                  child: Text('Coming Soon',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headline1
                          ?.copyWith(color: AppColors.primaries[6]))),
              Center(
                  child: Text(message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(color: AppColors.primaries[4]))),
            ],
          ),
        ],
      ),
    );
  }
}
