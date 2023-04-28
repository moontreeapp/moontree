import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:flutter/material.dart';
import 'package:client_back/services/services.dart';
import 'package:client_back/records/records.dart';
import 'package:client_back/streams/streams.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:client_front/presentation/services/services.dart' show sail;

class BackupIntro extends StatefulWidget {
  const BackupIntro({super.key});

  @override
  _BackupIntroState createState() => _BackupIntroState();
}

class _BackupIntroState extends State<BackupIntro> {
  bool? initialized;

  @override
  void initState() {
    streams.app.auth.verify.add(false);
    initialized = true;
  }

  @override
  Widget build(BuildContext context) => PageStructure(
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
            onPressed: () async {
              void sailTo() {
                if (Current.wallet is LeaderWallet) {
                  sail.to('/backup/seed', replaceOverride: true);
                } else {
                  sail.to('/backup/keypair', replaceOverride: true);
                }
              }

              if (services.password.askCondition) {
                await sail.to(
                  '/login/verify',
                  arguments: <String, Object>{
                    'buttonLabel': 'Submit',
                    'onSuccess': sailTo
                  },
                );
              } else {
                sailTo();
              }
            },
          ),
        ],
      );
}
