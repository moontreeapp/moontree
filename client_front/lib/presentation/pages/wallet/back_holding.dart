import 'package:flutter/material.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/utils/ext.dart';
import 'package:client_front/presentation/services/services.dart' show screen;

class BackHoldingScreen extends StatelessWidget {
  final String chainSymbol;
  const BackHoldingScreen({Key? key, this.chainSymbol = ''})
      : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('backHolding');

  @override
  Widget build(BuildContext context) => Container(
        height: screen.frontContainer.inverseMid,
        //color: Colors.transparent,
        alignment: Alignment.center,
        child: Container(
          transform: Matrix4.identity()..translate(0.0, -28.0, 0.0),
          height: 56,
          width: 56,
          child: CircleAvatar(
            backgroundColor: AppColors.primary,
            minRadius: 40,
            child: Text(chainSymbol.characters.firstOrNull ?? '?'),
          ),
        ),
      );
}
