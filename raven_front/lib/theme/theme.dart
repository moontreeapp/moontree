import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'color_gen.dart';

class Palette {
  static const Color ravenBlue = Color(0xFF2E3E80);
  //static const Color ravenBlue = Color(0xFF005898); // based off orange
  static const Color ravenOrange = Color(0xFFF15B22);
  static const Color primary = ravenBlue; //Color(0xFF2F4D7D);
}

// orange-green #b6f122
//

CustomTheme currentTheme = CustomTheme();

class CustomTheme with ChangeNotifier {
  static bool _isDarkTheme = true;
  static Color primaryColor = Color(0xFF5C6BC0);
  //static Color secondary = Color(0xFF5C6BC0);
  ThemeMode get currentTheme => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      backgroundColor: primaryColor,
      //primarySwatch: generateMaterialColor(Palette.ravenBlue),
      fontFamily: 'Nunito',
      //primaryColor: Colors.blue.shade900,
      indicatorColor: Color(0xffb6f122),
      //backgroundColor: Colors.white,
      //scaffoldBackgroundColor: Colors.white,
      //bottomAppBarColor: Colors.white,
      //dividerColor: Colors.black.withOpacity(0.12),
      dividerTheme: DividerThemeData(
          color: Colors.black.withOpacity(0.12), thickness: 1, indent: 70),
      //disabledColor: Colors.grey,
      //hintColor: Colors.grey[600],
      //textTheme: Typography.blackCupertino,
      //textTheme: TextTheme(
      //  headline1: TextStyle(color: Colors.black),
      //  headline2: TextStyle(color: Colors.black),
      //  bodyText1: TextStyle(color: Colors.black),
      //  bodyText2: TextStyle(color: Colors.black),
      //),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        //foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData.fallback(),
        centerTitle: false,
        //actionsIconTheme: IconThemeData,
        //titleSpacing: double,
        //toolbarHeight: double,
        //toolbarTextStyle: TextStyle,
        //titleTextStyle: TextStyle,
        //systemOverlayStyle: SystemUiOverlayStyle(
        //  statusBarIconBrightness: Brightness.dark,
        //  statusBarBrightness: Brightness.light,
        //  statusBarColor:
        //      Colors.white.withOpacity(.1), //Colors.transparent //Colors.white,
        //  //systemNavigationBarDividerColor: Colors.black.withOpacity(0.12)
        //),
      ),
      textTheme: TextTheme(
        headline5: TextStyle(
            fontSize: 24.0, letterSpacing: 2.0, color: Colors.grey.shade200),
        headline2: TextStyle(
            fontSize: 18.0, letterSpacing: 2.0, color: Colors.grey.shade200),
        headline3: TextStyle(color: Colors.grey.shade200),
        headline4: TextStyle(fontSize: 20, color: Colors.grey.shade900),
        headline6: TextStyle(
            fontSize: 18.0, letterSpacing: 1.5, color: Colors.grey.shade400),
        bodyText1: TextStyle(fontSize: 20.0),
        bodyText2: TextStyle(fontSize: 16.0),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: generateMaterialColor(Palette.ravenOrange),
      textTheme: TextTheme(
        headline1: TextStyle(fontSize: 24.0, letterSpacing: 2.0),
        headline2: TextStyle(
            fontSize: 18.0, letterSpacing: 2.0, color: Colors.grey.shade200),
        headline3: TextStyle(color: Colors.grey.shade200),
        headline4: TextStyle(color: Colors.grey.shade200),
        bodyText1: TextStyle(fontSize: 20.0),
        bodyText2: TextStyle(fontSize: 16.0),
      ),
      indicatorColor: Color(0xFFB6F122),
      //primaryColor: Colors.black,
      //primarySwatch: Colors.red,
      //backgroundColor: Colors.grey,
      //scaffoldBackgroundColor: Colors.grey,
      //textTheme: TextTheme(
      //  headline1: TextStyle(color: Colors.white),
      //  headline2: TextStyle(color: Colors.white),
      //  bodyText1: TextStyle(color: Colors.white),
      //  bodyText2: TextStyle(color: Colors.white),
      //),
    );
  }
}

//Brightness? primaryColorBrightness;
//Color? primaryColorLight;
//Color? primaryColorDark;
//Color? canvasColor;
//Color? shadowColor;
//Color? cardColor;
//Color? focusColor;
//Color? hoverColor;
//Color? highlightColor;
//Color? splashColor;
//InteractiveInkFeatureFactory? splashFactory;
//Color? selectedRowColor;
//Color? unselectedWidgetColor;
//Color? buttonColor;
//ButtonThemeData? buttonTheme;
//ToggleButtonsThemeData? toggleButtonsTheme;
//Color? secondaryHeaderColor;
//Color? textSelectionColor;
//Color? cursorColor;
//Color? textSelectionHandleColor;
//Color? backgroundColor;
//Color? dialogBackgroundColor;
//Color? indicatorColor;
//Color? errorColor;
//Color? toggleableActiveColor;
//String? fontFamily;
//TextTheme? textTheme;
//TextTheme? primaryTextTheme;
//TextTheme? accentTextTheme;
//InputDecorationTheme? inputDecorationTheme;
//IconThemeData? iconTheme;
//IconThemeData? primaryIconTheme;
//IconThemeData? accentIconTheme;
//SliderThemeData? sliderTheme;
//TabBarTheme? tabBarTheme;
//TooltipThemeData? tooltipTheme;
//CardTheme? cardTheme;
//ChipThemeData? chipTheme;
//TargetPlatform? platform;
//MaterialTapTargetSize? materialTapTargetSize;
//bool? applyElevationOverlayColor;
//PageTransitionsTheme? pageTransitionsTheme;
//AppBarTheme? appBarTheme;
//ScrollbarThemeData? scrollbarTheme;
//BottomAppBarTheme? bottomAppBarTheme;
//ColorScheme? colorScheme;
//DialogTheme? dialogTheme;
//FloatingActionButtonThemeData? floatingActionButtonTheme;
//NavigationRailThemeData? navigationRailTheme;
//Typography? typography;
////NoDefaultCupertinoThemeData? cupertinoOverrideTheme;
//SnackBarThemeData? snackBarTheme;
//BottomSheetThemeData? bottomSheetTheme;
//PopupMenuThemeData? popupMenuTheme;
//MaterialBannerThemeData? bannerTheme;
//DividerThemeData? dividerTheme;
//ButtonBarThemeData? buttonBarTheme;
//BottomNavigationBarThemeData? bottomNavigationBarTheme;
//TimePickerThemeData? timePickerTheme;
//TextButtonThemeData? textButtonTheme;
//ElevatedButtonThemeData? elevatedButtonTheme;
//OutlinedButtonThemeData? outlinedButtonTheme;
//TextSelectionThemeData? textSelectionTheme;
//DataTableThemeData? dataTableTheme;
//CheckboxThemeData? checkboxTheme;
//RadioThemeData? radioTheme;
//SwitchThemeData? switchTheme;
//ProgressIndicatorThemeData? progressIndicatorTheme;
//bool? fixTextFieldOutlineLabel;
//bool? useTextSelectionTheme;
//
