import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raven_front/theme/colors.dart';

CustomTheme currentTheme = CustomTheme();

class CustomTheme with ChangeNotifier {
  static bool _isDarkTheme = true;
  ThemeMode get currentTheme => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  static ThemeData get lightTheme {
    return ThemeData(
        brightness: Brightness.light,
        backgroundColor: AppColors.primary,
        primaryColor: AppColors.primary,
        disabledColor: AppColors.disabled,
        fontFamily: 'Nunito',
        dividerTheme: DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          indent: 70,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData.fallback(),
          centerTitle: false,
        ));
  }
}
