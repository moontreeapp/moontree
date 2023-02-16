import 'package:flutter/material.dart';

class FrontDrop extends StatelessWidget {
  final Color color;
  const FrontDrop({Key? key, this.color = Colors.white}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
    );
  }
}

class FrontDropWithChild extends StatelessWidget {
  final Color color;
  final Widget child;
  const FrontDropWithChild({
    Key? key,
    this.color = Colors.white,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: child);
  }
}
