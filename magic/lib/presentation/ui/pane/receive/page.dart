import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
            GestureDetector(
                onTap: () {
                  if (cubits.receive.state.address.isEmpty) {
                    cubits.receive.populateReceiveAddress(
                        cubits.holding.state.holding.blockchain!);
                  }
                  Clipboard.setData(
                      ClipboardData(text: cubits.receive.state.address));
                },
                child: Container(
                    height: screen.width - 32 * 4,
                    width: screen.width - 32 * 4,
                    color: Colors.grey,
                    child: QrImageView(
                        backgroundColor: Colors.white,
                        data: cubits.receive.state.address,
                        eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: AppColors.black),
                        dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.circle,
                            color: AppColors.black),
                        //foregroundColor: AppColors.primary,
                        //embeddedImage: Image.asset(
                        //        'assets/logo/moontree_logo.png')
                        //    .image,
                        size: screen.width - 32 * 2))),
            SelectableText.rich(
              TextSpan(
                text: '',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: AppColors.black87),
                children: <TextSpan>[
                  TextSpan(
                    text: cubits.receive.state.address.substring(0, 6),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: cubits.receive.state.address
                        .substring(6, cubits.receive.state.address.length - 6),
                  ),
                  TextSpan(
                    text: cubits.receive.state.address
                        .substring(cubits.receive.state.address.length - 6),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: cubits.receive.state.address));
                      cubits.toast.flash(
                          msg: const ToastMessage(
                              title: 'copied', text: 'to clipboard'));
                    },
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
                        ))))),
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
