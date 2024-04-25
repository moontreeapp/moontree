import 'package:flutter/material.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:magic/services/services.dart';

class ReceivePage extends StatelessWidget {
  const ReceivePage({super.key});

  @override
  Widget build(BuildContext context) => Container(
      height: screen.pane.midHeight,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
                height: screen.width - 32 * 4,
                width: screen.width - 32 * 4,
                color: Colors.grey),
            const Text('address'),
          ],
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                child: Container(
                    height: 64,
                    decoration: ShapeDecoration(
                      color: AppColors.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28 * 100),
                      ),
                    ),
                    child: Center(
                        child: Text(
                      'COPY',
                      style: AppText.button1.copyWith(color: Colors.white),
                    )))),
            const SizedBox(width: 16),
            Expanded(
                child: Container(
                    height: 64,
                    decoration: ShapeDecoration(
                      color: AppColors.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28 * 100),
                      ),
                    ),
                    child: Center(
                        child: Text(
                      'SHARE',
                      style: AppText.button1.copyWith(color: Colors.white),
                    )))),
          ],
        )
      ]));
}
