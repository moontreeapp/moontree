import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
//import 'package:client_back/streams/streams.dart'; // streams.app.path
import 'package:client_front/presentation/services/services.dart' show sail;

part 'state.dart';
// todo: the title doesn't need path, we should put something else there.
//       path used to be the title variable itself, but nothing outside this
//       title cubit should know what that actually is, so it doesn't make sense
//       to set it from the outside. it should be provided data with wich it can
//       deduce what the right title is. the path is available through
//       streams.app.path, so we don't need to provide it to this cubit.
//       we will need to provide other information though, eventually as we
//       fill out it's featureset.

class TitleCubit extends Cubit<TitleCubitState> {
  TitleCubit() : super(const TitleState(path: '/login/create'));

  static const Map<String, String> titles = {
    '/login/create': 'Welcome',
    '/login/create/native': 'Native Security',
    '/login/create/password': 'Create Password Login',
    '/login/native': 'Locked',
    '/login/password': 'Locked',
    '/wallet/holdings': 'Holdings',
    '/wallet/holding': 'Holding',
    '/wallet/holding/transaction': 'Transaction',
    '/manage': 'Manage',
    '/swap': 'Swap',
    '/menu': 'Menu',
    '/menu/settings': 'Settings',
    '/settings/example': 'Example',
  };

  void update({String? path, String? title}) => emit(TitleState(
        path: path ?? state.path,
        title: title ?? state.title,
      ));

  void reset() => emit(TitleState(
        path: state.path,
        title: null,
      ));

  /// returns override title, the title by location, or empty string.
  String get title => () {
        print(sail.latestLocation);
        return state.title ?? titles[sail.latestLocation] ?? 'Welcome';
      }();
}
