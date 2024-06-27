import 'package:flutter/material.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/services/services.dart';

class Scanner extends StatelessWidget {
  const Scanner({super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () => cubits.toast.flash(
              msg: const ToastMessage(
            title: 'To scanner',
            text: '',
          )),
      child: Container(
        height: 16 + screen.iconMedium + 16,
        width: 24 + screen.iconMedium,
        alignment: Alignment.centerLeft,
        color: Colors.transparent,
        child: Icon(Icons.qr_code_scanner_rounded,
            color: AppColors.white67, size: screen.iconMedium),
      ));
}
