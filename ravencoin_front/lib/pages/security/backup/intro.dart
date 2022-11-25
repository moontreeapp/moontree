import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

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
            back: BlankBack(),
            front: FrontCurve(
              child: components.page.form(
                context,
                columnWidgets: <Widget>[
                  Container(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'Your wallet is valuable.\nPlease create a backup!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1!
                            .copyWith(color: AppColors.black),
                      )),
                  SizedBox(height: 16),
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
                buttons: [
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
