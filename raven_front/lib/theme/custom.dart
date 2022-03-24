import 'package:flutter/material.dart';
import 'package:raven_front/theme/theme.dart';

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
        ),
        tooltipTheme: TooltipThemeData(preferBelow: true),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primary,
          selectionHandleColor: AppColors.primaryDisabled,
          selectionColor: AppColors.disabled,
        ),
        textTheme: TextTheme(
          headline1: AppText.h1,
          headline2: AppText.h2,
          subtitle1: AppText.subtitle1,
          subtitle2: AppText.subtitle2,
          bodyText1: AppText.body1,
          bodyText2: AppText.body2,
          caption: AppText.caption,
          button: AppText.button,
          overline: AppText.overline,
        ));
  }
}
