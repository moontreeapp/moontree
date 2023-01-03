// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/theme/colors.dart';
import 'package:client_front/widgets/assets/filters.dart';
//import 'package:client_front/utils/extensions.dart';

class icons {
  static Widget crypto(
    Security security, {
    double? height,
    double? width,
    bool circled = false,
  }) {
    if (security == pros.securities.EVR) {
      return evrmore(height: height, width: width, circled: circled);
    }
    if (security == pros.securities.EVRt) {
      return evrmoreTest(height: height, width: width, circled: circled);
    }
    if (security == pros.securities.RVN) {
      return ravencoin(height: height, width: width, circled: circled);
    }
    if (security == pros.securities.RVNt) {
      return ravencoinTest(height: height, width: width, circled: circled);
    }
    return ravencoin(height: height, width: width, circled: circled);
  }

  static Widget moontree({double? height, double? width}) => Image.asset(
        'assets/logo/moontree.png',
        height: height,
        width: width,
      );

  static Widget evrmore({
    double? height,
    double? width,
    bool circled = false,
  }) =>
      Image.asset(
        'assets/evr${circled ? 'circle' : ''}.png',
        height: height,
        width: width,
      );

  static Widget evrmoreTest({
    double? height,
    double? width,
    bool circled = false,
  }) =>
      ColorFiltered(
          colorFilter: filters.greyscale,
          child: evrmore(height: 24, width: 24, circled: true));

  static Widget ravencoin({
    double? height,
    double? width,
    bool circled = false,
  }) =>
      Image.asset(
        'assets/rvn${circled ? 'circle' : ''}.png',
        height: height,
        width: width,
      );

  static Widget ravencoinTest({
    double? height,
    double? width,
    bool circled = false,
  }) =>
      ColorFiltered(
          colorFilter: filters.greyscale,
          child: ravencoin(height: height, width: width, circled: circled));
}

class SvgIcons {
  static Widget get moontreeSVG => //Container(
      //child:
      SvgPicture.asset('assets/logo/moontree_logo.svg')
      //,
      //height: .1534.ofMediaHeight(context),
      //)
      ;
  //static Widget get moontree =>
  //    Container(child: SvgPicture.asset('assets/logo/moontree.png'));
  //static Widget get evrmore =>
  //    Container(child: SvgPicture.asset('assets/evr.png'));
  //static Widget get evrmoreTest =>
  //    Container(child: SvgPicture.asset('assets/evr.png'));
  static Widget get ravencoin => SvgPicture.asset('assets/rvn.svg');
  //static Widget get ravencoinTest =>
  //    Container(child: SvgPicture.asset('assets/rvn.png'));

  static Widget get circle => Container(
      height: 24,
      width: 24,
      decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary,
          )),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(100.0),
          child: Center(
              child: Container(
            child: ravencoin,
            //Icon(
            //size: (height + width) / 3,
            //color:getIndicatorColor(imageDetails.background)
            //)
          ))));
}
