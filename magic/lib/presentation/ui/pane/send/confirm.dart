import 'package:flutter/material.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/theme/extensions.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:magic/presentation/widgets/other/other.dart';
import 'package:magic/services/services.dart';

class ConfirmContent extends StatelessWidget {
  const ConfirmContent({super.key});

  void _send() {
    // sign it.
    // broadcast it.
  }

  @override
  Widget build(BuildContext context) => Container(
      height: screen.pane.midHeight,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ConfirmationItem(label: 'To:', display: <TextSpan>[
              TextSpan(
                  text: 'address',
                  style: Theme.of(context).textTheme.body1.copyWith(
                        fontWeight: FontWeight.normal,
                        color: AppColors.black87,
                      )),
            ]),
            ConfirmationItem(label: 'Amount:', display: <TextSpan>[
              TextSpan(
                  text: '21,000,000,000',
                  style: Theme.of(context).textTheme.body1.copyWith(
                        fontWeight: FontWeight.normal,
                        color: AppColors.black87,
                      )),
              TextSpan(
                  text: '.00000000',
                  style: Theme.of(context).textTheme.body1.copyWith(
                      fontWeight: FontWeight.normal,
                      color: AppColors.black60,
                      fontSize: 12)),
            ]),
            ConfirmationItem(label: 'Fee:', display: <TextSpan>[
              TextSpan(
                  text: 'display.coin.whole()',
                  style: Theme.of(context).textTheme.body1.copyWith(
                        fontWeight: FontWeight.normal,
                        color: AppColors.black87,
                      )),
              TextSpan(
                  text: 'display.coin.spacedPart()',
                  style: Theme.of(context).textTheme.body1.copyWith(
                      fontWeight: FontWeight.normal,
                      color: AppColors.black60,
                      fontSize: 12)),
            ]),
          ],
        ),
        GestureDetector(
            onTap: _send,
            child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.successDark,
                    width: 4,
                  ),
                ),
                child: Center(
                    child: Text(
                  'SEND',
                  style: AppText.button1
                      .copyWith(fontSize: 16, color: Colors.white),
                )))),
      ]));
}

class ConfirmationItem extends StatelessWidget {
  final String label;
  final List<TextSpan> display;
  final Widget? overrideDisplay;
  const ConfirmationItem({
    super.key,
    required this.label,
    required this.display,
    this.overrideDisplay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        //color: Colors.red,
        width: screen.width,
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.body1),
            if (overrideDisplay != null)
              overrideDisplay!
            else
              RichText(
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                text: TextSpan(
                  style:
                      Theme.of(context).textTheme.body1, // Default text style
                  children: display,
                ),
              )
          ],
        ));
  }
}
