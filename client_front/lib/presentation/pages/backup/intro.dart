import 'package:flutter/material.dart';
import 'package:client_back/streams/streams.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:client_front/presentation/services/services.dart' show sail;

class BackupIntro extends StatelessWidget {
  const BackupIntro({super.key});

  @override
  Widget build(BuildContext context) {
    streams.app.auth.verify.add(false);
    return PageStructure(
      children: [
        Container(
            alignment: Alignment.topCenter,
            child: Text(
              'Please create a backup!',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: AppColors.black),
            )),
        Container(
            alignment: Alignment.topCenter,
            child: Text(
              'You are about to backup your seed words.\nKeep it secret, keep it safe.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: AppColors.error),
            ))
      ],
      firstLowerChildren: [
        BottomButton(
          label: 'BACKUP',
          onPressed: () => sail.to('/backup/seed'),
        ),
      ],
    );
  }
}
