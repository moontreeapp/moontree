import 'package:client_back/client_back.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/infrastructure/services/lookup.dart';

part 'state.dart';

class LocationCubit extends Cubit<LocationCubitState> {
  LocationCubit() : super(const LocationState());

  List<void Function(LocationCubitState, LocationCubitState)> hooks = [];

  void update({
    String? path,
    Section? section,
    String? symbol,
    bool? menuOpen,
    bool? dataTab,
    bool? submitting,
  }) {
    final newState = LocationState(
      path: path ?? state.path,
      section: section ?? state.section,
      sector: LocationCubitState.sectorSections.contains(section)
          ? section
          : state.sector,
      symbol: symbol ?? state.symbol,
      menuOpen: menuOpen ?? state.menuOpen,
      dataTab: dataTab ?? state.dataTab,
      submitting: submitting ?? state.submitting,
    );
    for (final hook in hooks) {
      hook(state, newState);
    }
    emit(newState);
  }

  void reset() => emit(LocationState());
  void refresh() {
    update(submitting: true);
    update(submitting: false);
  }

  Symbol? get symbol => state.symbol == null ? null : Symbol(state.symbol!)();
  bool get menuOpened => state.menuOpen;
  bool get searchButtonShown => state.searchButtonShown;
}
