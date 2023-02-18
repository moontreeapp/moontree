import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'state.dart';

class TitleCubit extends Cubit<TitleCubitState> {
  TitleCubit() : super(const TitleState(path: '/login/create'));

  static const Map<String, String> titles = {
    '/login/create': 'Welcome',
    '/login/create/native': 'Create Login',
    '/login/create/password': 'Create Login',
    '/login/native': 'Login',
    '/login/password': 'Login',
    '/wallet/holdings': 'Holdings',
    '/wallet/holding': 'Holding',
    '/wallet/holding/transaction': 'Transaction',
    '/manage': 'Manage',
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
  String get title => state.title ?? titles[state.path] ?? '';
}
