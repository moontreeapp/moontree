import 'package:flutter/material.dart';
import 'package:moontree/presentation/theme/colors.dart';
import 'package:moontree/presentation/theme/text.dart';
import 'package:moontree/presentation/widgets/other/other.dart';
import 'package:moontree/services/services.dart';

class SendPage extends StatelessWidget {
  const SendPage({super.key});

  @override
  Widget build(BuildContext context) => Container(
      height: screen.pane.midHeight,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextFieldFormatted(
              autocorrect: false,
              textInputAction: TextInputAction.next,
              labelText: 'To',
              suffixIcon: Icon(Icons.qr_code_scanner, color: AppColors.black60),
            ),
            SizedBox(height: 4),
            TextFieldFormatted(
              autocorrect: false,
              textInputAction: TextInputAction.done,
              labelText: 'Amount',
            ),
          ],
        ),
        Container(
            height: 64,
            decoration: ShapeDecoration(
              color: AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28 * 100),
              ),
            ),
            child: Center(
                child: Text(
              'SEND',
              style: AppText.button1.copyWith(color: Colors.white),
            ))),
      ]));
}
