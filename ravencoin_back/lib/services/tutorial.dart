import 'package:ravencoin_back/ravencoin_back.dart';

class TutorialService {
  List<TutorialStatus> get completed => <TutorialStatus>[
        ...pros.settings.primaryIndex.getOne(SettingName.tutorial_status)!.value
      ];

  List<TutorialStatus> get missing => SettingProclaim.tutorials
      .where((tutorial) => !completed.contains(tutorial))
      .toList();

  Future complete(TutorialStatus tutorial) async => pros.settings.save(
        Setting(
            name: SettingName.tutorial_status,
            value: completed + <TutorialStatus>[tutorial]),
      );

  Future clear() async => pros.settings.save(
        Setting(name: SettingName.tutorial_status, value: <TutorialStatus>[]),
      );
}
