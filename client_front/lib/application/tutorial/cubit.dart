// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart' show Cubit;
import 'package:client_back/client_back.dart';
import 'package:equatable/equatable.dart';

part 'state.dart';

class TutorialCubit extends Cubit<TutorialCubitState> {
  TutorialCubit() : super(TutorialState(showTutorials: <TutorialStatus>[]));

  void update({List<TutorialStatus>? showTutorials}) {
    emit(TutorialState(showTutorials: showTutorials ?? state.showTutorials));
  }

  /// we instead use the proclaim as single source of truth
  //void _remove(TutorialStatus tutorial) => update(
  //    showTutorials: state.showTutorials.where((e) => e != tutorial).toList());

  Future<void> viewed(TutorialStatus tutorial) async {
    await complete(tutorial);
    load();
  }

  void load() => update(showTutorials: missing);

  //List<TutorialStatus> get completed => List<TutorialStatus>.from(
  //    pros.settings.primaryIndex.getOne(SettingName.tutorial_status)!.value
  //        as List<String>);

  List<TutorialStatus> get completed {
    final names = TutorialStatus.values.map((e) => e.name);
    final List<TutorialStatus> comps = [];
    for (final x in pros.settings.primaryIndex
        .getOne(SettingName.tutorial_status)!
        .value) {
      if (names.contains(x)) {
        comps.add(TutorialStatus.values.firstWhere((e) => e.name == x));
      }
    }
    return comps;
  }

  List<TutorialStatus> get missing => TutorialStatus.values
      .where((TutorialStatus tutorial) => !completed.contains(tutorial))
      .toList();

  Future<Change<Setting>?> complete(TutorialStatus tutorial) async =>
      pros.settings.save(Setting(
          name: SettingName.tutorial_status,
          value:
              [for (final x in completed) x.name] + <String>[tutorial.name]));

  Future<Change<Setting>?> clear() async => pros.settings.save(
      const Setting(name: SettingName.tutorial_status, value: <String>[]));
}

TutorialStatus enumFromString(String value) {
  return TutorialStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => null,
  );
}
