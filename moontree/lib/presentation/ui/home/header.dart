import 'package:flutter/material.dart';
import 'package:moontree/services/services.dart' show screen;
import 'package:moontree/presentation/theme/extensions.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) => Container(
      height: 56,
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 3),
        ),
        Text('header',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.h2!.copyWith(
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 1.0,
                  color: Color.fromRGBO(0, 0, 0, 0.50),
                ),
              ],
            )),
        const SizedBox(height: 30, width: 30)
      ]));
}

class HomeOverlay extends StatelessWidget {
  const HomeOverlay({super.key});

  @override
  Widget build(BuildContext context) => Container(
      height: screen.app.displayHeight,
      alignment: Alignment.topCenter,
      child: HomeHeader());
}
