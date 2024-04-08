import 'package:magic/presentation/utils/animation.dart';
import 'package:flutter/material.dart';
import 'package:magic/presentation/theme/theme.dart';

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
      colorScheme: AppColors.colorScheme,
      primaryColor: AppColors.primary,
      disabledColor: AppColors.disabled,
      fontFamily: 'Nunito',
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        indent: 70,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData.fallback(),
        centerTitle: false,
      ),
      tooltipTheme: const TooltipThemeData(preferBelow: true),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionHandleColor: AppColors.primaryDisabled,
        selectionColor: AppColors.disabled,
      ),
      datePickerTheme: DatePickerThemeData(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(28), // Adjust the border radius as desired
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppText.h1,
        displayMedium: AppText.h2,
        displaySmall: AppText.h2,
        titleLarge: AppText.h1,
        titleMedium: AppText.h2,
        titleSmall: AppText.h2,
        bodyLarge: AppText.body1,
        bodyMedium: AppText.body2,
        bodySmall: AppText.body2,
        labelLarge: AppText.button1,
        labelSmall: AppText.overline,
        /*(
            displayLarge == null &&
            displayMedium == null &&
            displaySmall == null &&
            headlineMedium == null &&
            headlineSmall == null &&
            titleLarge == null &&
            titleMedium == null &&
            titleSmall == null &&
            bodyLarge == null &&
            bodyMedium == null &&
            bodySmall == null &&
            labelLarge == null &&
            labelSmall == null) ||
         (
          headline1 == null &&
          headline2 == null &&
          headline3 == null &&
          headline4 == null &&
          headline5 == null &&
          headline6 == null &&
          subtitle1 == null &&
          subtitle2 == null &&
          bodyText1 == null &&
          bodyText2 == null &&
          caption == null &&
          button == null &&
          overline == null),*/
      ),

      /// part of `routes` solution rather than the `onGenerateRoute` in main
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeInPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeInPageTransitionsBuilder(),
        },
      ),
    );
  }
}
