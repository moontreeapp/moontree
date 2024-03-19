import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/presentation/components/icons.dart';
import 'package:moontree/presentation/layers/profile/components/content/picture.dart';
import 'package:moontree/presentation/theme/colors.dart';
import 'package:moontree/presentation/theme/extensions.dart';

class VideoOverlay extends StatelessWidget {
  const VideoOverlay({super.key});

  @override
  Widget build(BuildContext context) => Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          RawProfilePicture(
            size: 36,
            photo: cubits.profile.state.image,
          ),
          SvgPicture.asset(
            HypyrIcons.homeReplyLoc,
            height: 36,
            width: 36,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
          Opacity(
              opacity: .87,
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                  alignment: Alignment.center,
                  height: 32,
                  //width: 83,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: AppColors.primary,
                  ),
                  child: Text('FOLLOW',
                      style: Theme.of(context)
                          .textTheme
                          .button1!
                          .copyWith(height: 1.4, color: Colors.white)))),
          SvgPicture.asset(
            HypyrIcons.homeAwardLoc,
            height: 36,
            width: 36,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
          SvgPicture.asset(
            HypyrIcons.shareLightLoc,
            height: 36,
            width: 36,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          )
        ]),
      ]));
}
