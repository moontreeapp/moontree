import 'package:client_back/joins/joins.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:client_front/presentation/services/services.dart' show sail;

part 'state.dart';

class TitleCubit extends Cubit<TitleCubitState> {
  TitleCubit() : super(const TitleState());

  void update({String? title, bool? editable}) => emit(TitleState(
        title: title ?? state.title,
        editable: editable ?? state.editable,
      ));

  void reset() => emit(TitleState(title: null, editable: false));

  /// returns override title, the title by location, or empty string.
  String get title {
    if (showWalletName) {
      return Current.wallet.name;
    }
    if (['/wallet/holding', '/manage/holding'].contains(sail.latestLocation)) {
      return Current.holding.shortName; // should be holding name
    }
    return state.title ?? sail.latestLocation ?? ' ';
  }

  bool get showWalletName => [
        '/wallet/holdings',
        '/manage/holdings',
        '/swap/holdings',
      ].contains(sail.latestLocation);
}
