import 'package:client_back/records/types/chain.dart';
import 'package:client_back/records/wallets/wallet.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

part 'state.dart';

class LocationCubit extends Cubit<LocationCubitState> {
  LocationCubit() : super(const LocationState());

  void update({String? path, Section? section, String? symbol}) =>
      emit(LocationState(
        path: path ?? state.path,
        section: section ?? state.section,
        symbol: symbol ?? state.symbol,
      ));

  void reset() => emit(LocationState(path: null, section: null, symbol: null));
}
