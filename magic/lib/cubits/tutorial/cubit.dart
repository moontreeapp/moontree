import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';

part 'state.dart';

enum TutorialStatus {
  blockchain,
  wallet,
}

class TutorialCubit extends UpdatableCubit<TutorialState> {
  TutorialCubit()
      : super(const TutorialState(
            showTutorials: <TutorialStatus>[], flicked: false));
  @override
  String get key => 'tutorial';
  @override
  void reset() => emit(
      const TutorialState(showTutorials: <TutorialStatus>[], flicked: false));
  @override
  void setState(TutorialState state) => emit(state);
  @override
  void refresh() {}
  @override
  void activate() => update();
  @override
  void deactivate() => update();
  @override
  void update({
    List<TutorialStatus>? showTutorials,
    bool? flicked,
  }) {
    emit(TutorialState(
      showTutorials: showTutorials ?? state.showTutorials,
      flicked: flicked ?? state.flicked,
    ));
  }

  void flicked() => update(flicked: true);

  /// we instead use the proclaim as single source of truth
  //void _remove(TutorialStatus tutorial) => update(
  //    showTutorials: state.showTutorials.where((e) => e != tutorial).toList());

  //Future<void> viewed(TutorialStatus tutorial) async {
  //  await complete(tutorial);
  //  load();
  //}

  void load() => update(showTutorials: missing);

  List<TutorialStatus> get completed => [];
  //List<TutorialStatus>.from(
  //    pros.settings.primaryIndex.getOne(SettingName.tutorial_status)!.value
  //        as List<dynamic>);

  List<TutorialStatus> get missing => [];

  @override
  void hide() {
    // TODO: implement hide
  }
  //TutorialStatus.values
  //    .where((TutorialStatus tutorial) => !completed.contains(tutorial))
  //    .toList();

  //Future<Change<Setting>?> complete(TutorialStatus tutorial) async =>
  //    pros.settings.save(Setting(
  //        name: SettingName.tutorial_status, value: completed + [tutorial]));

  //Future<Change<Setting>?> clear() async =>
  //pros.settings.save(const Setting(
  //    name: SettingName.tutorial_status, value: <TutorialStatus>[]));
}
