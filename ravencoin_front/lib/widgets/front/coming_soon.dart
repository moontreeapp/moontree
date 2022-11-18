import 'package:flutter/material.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/theme/colors.dart';
import 'package:utils/list.dart' show range;

enum PlaceholderType { wallet, asset, swap }

class ComingSoonPlaceholder extends StatelessWidget {
  final String header;
  final String message;
  final PlaceholderType placeholderType;
  final ScrollController? scrollController;
  final Widget? behavior;

  const ComingSoonPlaceholder({
    this.scrollController,
    this.header = 'Coming Soon',
    this.message = 'Loading...',
    this.placeholderType = PlaceholderType.wallet,
    this.behavior = null,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height - 118; // -56 (navbar tall)
    final body = SingleChildScrollView(
      controller: scrollController,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              for (var _ in range(19))
                placeholderType == PlaceholderType.wallet
                    ? components.empty.holdingPlaceholder(context)
                    : placeholderType == PlaceholderType.asset
                        ? components.empty.assetPlaceholder(context)
                        : components.empty.swapPlaceholder(context)
            ],
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IgnorePointer(
                  child: Container(
                    height: height / 2,
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
                IgnorePointer(
                  child: Container(
                    height: height / 2,
                    color: Colors.white,
                  ),
                ),
              ]),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(height: (height - 16 - 56) / 2),
              Center(
                  child: Text(header,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headline1
                          ?.copyWith(color: AppColors.primaries[7]))),
              Center(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.copyWith(color: AppColors.primary)),
              )),
              if (behavior != null)
                Center(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 40),
                  child: behavior,
                )),
            ],
          ),
        ],
      ),
    );

    if (behavior == null) {
      return IgnorePointer(child: body);
    }
    return body;
  }
}
