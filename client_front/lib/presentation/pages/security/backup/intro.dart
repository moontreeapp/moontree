import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/presentation/components/components.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/widgets/widgets.dart';

class BackupIntro extends StatefulWidget {
  final dynamic data;
  const BackupIntro({this.data}) : super();

  @override
  _BackupIntroState createState() => _BackupIntroState();
}

class _BackupIntroState extends State<BackupIntro> {
  @override
  void initState() {
    super.initState();
    streams.app.verify.add(false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    streams.app.lead.add(LeadIcon.none);
    return WillPopScope(
        onWillPop: () async => false,
        child: BackdropLayers(
            back: const BlankBack(),
            front: FrontCurve(
              child: components.page.form(
                context,
                columnWidgets: <Widget>[
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
                  const SizedBox(height: 16),
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
                buttons: <Widget>[
                  components.buttons.actionButton(
                    context,
                    label: 'BACKUP',
                    onPressed: () {
                      Navigator.of(context).pushNamed('/security/backup');
                    },
                  ),
                ],
              ),
            )));
  }
}
