import 'package:ravencoin_back/ravencoin_back.dart';

class TutorialService {
  List<TutorialStatus> get completed =>
      (pros.settings.primaryIndex.getOne(SettingName.tutorial_status)!.value
          as List<TutorialStatus>);

  List<TutorialStatus> get missing => SettingProclaim.tutorials
      .where((tutorial) => !completed.contains(tutorial))
      .toList();

  Future complete(TutorialStatus tutorial) async => await pros.settings.save(
        Setting(
            name: SettingName.tutorial_status,
            value: completed + <TutorialStatus>[tutorial]),
      );

  Future clear() async => await pros.settings.save(
        Setting(name: SettingName.tutorial_status, value: <TutorialStatus>[]),
      );
}
