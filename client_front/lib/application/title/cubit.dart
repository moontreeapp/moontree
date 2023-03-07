import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:client_front/presentation/services/services.dart' show sail;

part 'state.dart';

class TitleCubit extends Cubit<TitleCubitState> {
  TitleCubit() : super(const TitleState());

  void update({String? title}) => emit(TitleState(
        title: title ?? state.title,
      ));

  void reset() => emit(TitleState(title: null));

  /// returns override title, the title by location, or empty string.
  String get title {
    if ([
      '/wallet/holdings',
      '/manage',
      '/swap',
    ].contains(sail.latestLocation)) {
      return Current.wallet.name;
    }
    if (sail.latestLocation == '/wallet/holding') {
      return 'Holding'; // should be holding name
    }
    return state.title ?? sail.latestLocation ?? ' ';
  }
}
