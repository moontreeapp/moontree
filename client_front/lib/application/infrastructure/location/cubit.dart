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
  }) {
    final newState = LocationState(
      path: path ?? state.path,
      section: section ?? state.section,
      sector: LocationCubitState.sectorSections.contains(section)
          ? section
          : state.sector,
      symbol: symbol ?? state.symbol,
      menuOpen: menuOpen ?? state.menuOpen,
    );
    for (final hook in hooks) {
      hook(state, newState);
    }
    emit(newState);
  }

  void reset() => emit(LocationState());

  bool get menuOpen => state.menuOpen;
}
