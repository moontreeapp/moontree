import 'package:flutter/material.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/presentation/theme/extensions.dart';
import 'package:moontree/services/services.dart' show screen;

class AppbarHeader extends StatelessWidget {
  const AppbarHeader({super.key});

  @override
  Widget build(BuildContext context) => Container(
      height: screen.appbar.height,
      width: screen.width,
      alignment: Alignment.center,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
                onTap: () => cubits.pane.update(height: screen.pane.minHeight),
                child: Text('menu',
                    style: Theme.of(context)
                        .textTheme
                        .h2!
                        .copyWith(color: Colors.white, shadows: [
                      const Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 1.0,
                          color: Color.fromRGBO(0, 0, 0, 0.50))
                    ]))),
            GestureDetector(
                onTap: () => cubits.pane.update(height: screen.pane.midHeight),
                child: Text('title',
                    style: Theme.of(context)
                        .textTheme
                        .h2!
                        .copyWith(color: Colors.white, shadows: [
                      const Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 1.0,
                          color: Color.fromRGBO(0, 0, 0, 0.50))
                    ]))),
            GestureDetector(
                onTap: () => cubits.pane.update(height: screen.pane.maxHeight),
                child: Text('icons',
                    style: Theme.of(context)
                        .textTheme
                        .h2!
                        .copyWith(color: Colors.white, shadows: [
                      const Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 1.0,
                          color: Color.fromRGBO(0, 0, 0, 0.50))
                    ]))),
          ]));
}
