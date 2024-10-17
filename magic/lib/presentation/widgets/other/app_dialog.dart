import 'dart:io';
import 'package:flutter/material.dart';
import 'package:magic/presentation/theme/colors.dart';

void showUSBDebuggingWarningDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      bool isChecked = false;
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            backgroundColor: AppColors.backhalf,
            title: const Text('Warning'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Your mobile device is at risk of being hacked. We strongly recommend'
                  ' disabling USB debugging before using the Magic Wallet App.'
                  ' To disable USB debugging, go to your device\'s Settings, '
                  'select Developer Options, and then turn off USB debugging. Alternatively,'
                  ' you can proceed with USB debugging enabled by selecting the checkbox below.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                CheckboxListTile(
                  title: const Text(
                    'I understand the risks and want to proceed with USB debugging enabled',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  value: isChecked,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  contentPadding: EdgeInsets.zero,
                  hoverColor: Colors.transparent,
                  checkColor: AppColors.white,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.button,
                ),
              ],
            ),
            actions: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.backhalf,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(200),
                          side: const BorderSide(
                              color: AppColors.button, width: 1),
                        ),
                      ),
                      child: const Text(
                        'Quit',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => exit(0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isChecked ? 1 : 0.5,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.button,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(200),
                          ),
                        ),
                        onPressed: isChecked
                            ? () {
                                Navigator.of(context).pop();
                              }
                            : null,
                        child: const Text(
                          'Proceed',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}
