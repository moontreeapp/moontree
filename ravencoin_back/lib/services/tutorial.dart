import 'package:ravencoin_back/ravencoin_back.dart';

class TutorialService {
  List<TutorialStatus> get completed => List<TutorialStatus>.from(
      pros.settings.primaryIndex.getOne(SettingName.tutorial_status)!.value
          as List<dynamic>);

  List<TutorialStatus> get missing => SettingProclaim.tutorials
      .where((TutorialStatus tutorial) => !completed.contains(tutorial))
      .toList();

  Future<Change<Setting>?> complete(TutorialStatus tutorial) async =>
      pros.settings.save(
        Setting(
            name: SettingName.tutorial_status,
            value: completed + <TutorialStatus>[tutorial]),
      );

  Future<Change<Setting>?> clear() async => pros.settings.save(
        Setting(name: SettingName.tutorial_status, value: <TutorialStatus>[]),
      );
}
