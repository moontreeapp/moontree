import 'package:client_back/joins/joins.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:client_front/presentation/services/services.dart' show sail;
import 'package:client_front/presentation/components/components.dart'
    as components;

part 'state.dart';

class TitleCubit extends Cubit<TitleCubitState> {
  TitleCubit() : super(const TitleState());

  void update({
    String? title,
    bool? editable,
    bool? submitting,
  }) =>
      emit(TitleState(
        title: title ?? state.title,
        editable: editable ?? state.editable,
        submitting: submitting ?? state.submitting,
      ));

  void reset() => emit(TitleState(title: null, editable: false));
  void refresh() {
    update(submitting: true);
    update(submitting: false);
  }

  /// returns override title, the title by location, or empty string.
  String get title {
    if (components.cubits.location.menuOpened &&
        components.cubits.backContainer.state.path == '/menu/settings') {
      return 'Settings';
    }
    if (showWalletName) {
      return Current.wallet.name;
    }
    if ([
      '/wallet/holding', /*'/manage/holding'*/ // show Manage
    ].contains(sail.latestLocation)) {
      return Current.holding.shortName;
    }
    if (sail.latestLocation == '/manage/create') {
      return '${state.title ?? 'Create'} ${components.cubits.simpleCreateForm.state.assetCreationName}';
    }
    if (sail.latestLocation == '/manage/reissue') {
      return '${state.title ?? 'Reissue'} ${components.cubits.simpleReissueForm.state.assetReissueName}';
    }
    return state.title ?? sail.latestLocation ?? ' ';
  }

  bool get showWalletName => [
        '/wallet/holdings',
        '/manage/holdings',
        '/swap/holdings',
      ].contains(sail.latestLocation);
}
