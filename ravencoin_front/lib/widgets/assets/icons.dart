import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ravencoin_front/theme/colors.dart';
//import 'package:ravencoin_front/utils/extensions.dart';

class icons {
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

  static Widget evrmoreTest({double? height, double? width}) => Image.asset(
        'assets/evr.png',
        height: height,
        width: width,
      );

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

  static Widget ravencoinTest({double? height, double? width}) => Image.asset(
        'assets/rvn.png',
        height: height,
        width: width,
      );
}

class svgIcons {
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
  static Widget get ravencoin =>
      Container(child: SvgPicture.asset('assets/rvn.svg'));
  //static Widget get ravencoinTest =>
  //    Container(child: SvgPicture.asset('assets/rvn.png'));

  static Widget get circle => Container(
      height: 24,
      width: 24,
      decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(
            width: 1,
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
