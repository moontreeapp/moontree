import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/widgets/widgets.dart';

class ComingSoonPlaceholder extends StatelessWidget {
  final String message;
  final bool returnHome;

  const ComingSoonPlaceholder({
    this.message = 'Loading...',
    this.returnHome = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FrontCurve(
      child: Stack(
        children: [
          ListView(
            children: [components.empty.assetPlaceholder(context)],
          ),
          IgnorePointer(
            child: Container(
              height: MediaQuery.of(context).size.height * .72,
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
              Text('Coming Soon', style: Theme.of(context).textTheme.headline1),
              Text(message, style: Theme.of(context).textTheme.bodyText1),
            ],
          ),
        ],
      ),
    );
  }
}
