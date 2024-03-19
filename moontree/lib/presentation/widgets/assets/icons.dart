import 'package:flutter/material.dart'
    show
        Alignment,
        BoxDecoration,
        BoxFit,
        BoxShape,
        ClipOval,
        ColorFilter,
        Colors,
        Container,
        FilterQuality,
        Icon,
        IconData,
        Icons,
        Image,
        Widget;
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moontree/presentation/theme/colors.dart';
import 'package:moontree/services/services.dart' show screen;

enum TagToolActivity {
  options,
  selected,
  unselected,
}

enum TagToolChoice {
  zoom,
  invite,
  one,
  many,
  tag,
  time,
  expire,
  view,
}

class ToolIcons {
  static const String base = 'assets/icons/tools/';
  static const String ext = '.svg';
  static String loc(TagToolActivity activity, TagToolChoice choice) =>
      base + activity.name + '/' + choice.name + ext;
}

class NavbarIcons {
  static const String base = 'assets/icons/navbar/';
  static const String ext = '.svg';
  static Widget home(bool selected) => Container(
      alignment: Alignment.center,
      //color: cubits.navbar.atCreate ? Colors.black38 : Colors.black,
      color: Colors.black,
      child: selected
          ? Icon(Hicons.home_2_bold, color: Colors.white)
          : Icon(Hicons.home_2_light_outline, color: Colors.white));
  static Widget explore(bool selected) => Container(
      alignment: Alignment.center,
      //color: cubits.navbar.atCreate ? Colors.black38 : Colors.black,
      color: Colors.black,
      child: selected
          ? Icon(Hicons.search_2_bold, color: Colors.white)
          : Icon(Hicons.search_2_light_outline, color: Colors.white));

  static Widget create(bool selected) => Container(
      alignment: Alignment.center,
      //color: cubits.navbar.atCreate ? Colors.black38 : Colors.black,
      color: Colors.black,
      child: SvgPicture.asset(
        '${base}create${selected ? '_selected' : ''}.svg',
        height: screen.navbar.largeIconHeight,
        width: screen.navbar.largeIconHeight,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        //colorFilter: selected
        //    ? ColorFilter.mode(AppColors.primary, BlendMode.modulate)
        //    : null,
      ));
  static Widget crew(bool selected, [bool notifications = false]) => Container(
      alignment: Alignment.center,
      //color: cubits.navbar.atCreate ? Colors.black38 : Colors.black,
      color: Colors.black,
      child: SvgPicture.asset(
        '${base}crew${selected ? '_selected' : ''}${notifications ? '_notifications' : ''}.svg',
        height: screen.navbar.iconHeight,
        width: screen.navbar.iconHeight,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        //colorFilter: selected
        //    ? ColorFilter.mode(AppColors.primary, BlendMode.modulate)
        //    : null,
      ));
  static Widget profile({
    required bool selected,
    String? photo,
  }) =>
      Container(
          alignment: Alignment.center,
          //color: cubits.navbar.atCreate ? Colors.black38 : Colors.black,
          color: Colors.black,
          child: Container(
              height: screen.navbar.largeIconHeight - 4,
              width: screen.navbar.largeIconHeight - 4,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Colors.white : Colors.transparent,
              ),
              child: Container(
                  height: screen.navbar.iconHeight,
                  width: screen.navbar.iconHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? Colors.black : Colors.transparent,
                  ),
                  child: ClipOval(
                    child: photo == null
                        ? Icon(Icons.person)
                        : HypyrIcons.profilePhoto(
                            photo,
                            height: screen.navbar.iconHeight - 4,
                            width: screen.navbar.iconHeight - 4,
                            fit: BoxFit.cover,
                          ),
                  ))));
}

class SelectionIcons {
  static const String base = 'assets/icons/selection/';
  static const String ext = '.svg';

  static Widget star(bool selected) => Container(
      alignment: Alignment.center,
      child: SvgPicture.asset(
        '${base}star_${selected ? '' : 'un'}selected.svg',
        height: screen.home.selectionIconHeight,
        width: screen.home.selectionIconHeight,
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ));
}

class PlacementIcons {
  static const String base = 'assets/icons/placement/';
  static const String ext = '.svg';

  static String placementLoc(int place, String? period) =>
      '${base}${place}${period ?? 'all'}.svg';
}

class ExploreIcons {
  static const String base = 'assets/icons/hypyr/explore-';
  static const String ext = '.svg';
  static const String search = 'search-ends';
  static const String searchStart = 'search-start';
  static const String searchEnd = 'search-end';
  static const String orb = 'orb';

  static String exploreLoc(String thing) => '${base}${thing}${ext}';
  static SvgPicture get(String thing) => SvgPicture.asset(
        ExploreIcons.exploreLoc(thing),
        height: 56,
        width: 56,
        fit: BoxFit.contain,
        alignment: Alignment.center,
      );
}

class NotificationIcons {
  static const String base = 'assets/icons/hypyr/notification-';
  static const String ext = '.svg';
  static const String theyPlacedFirst = 'they-placed-first';
  static const String youPlacedFirst = 'you-placed-first';
  static const String playVideo = 'play-video';
  static const String challenge = 'challenge';
  static const String orb = 'orb';

  static String notificationLoc(String thing) => '${base}${thing}${ext}';
  static SvgPicture get(String thing) => SvgPicture.asset(
        NotificationIcons.notificationLoc(thing),
        height: 24,
        width: 24,
        fit: BoxFit.contain,
        alignment: Alignment.center,
      );
  static SvgPicture getOrb() => SvgPicture.asset(
        NotificationIcons.notificationLoc(NotificationIcons.orb),
        height: 56,
        width: 56,
        fit: BoxFit.contain,
        alignment: Alignment.center,
      );
}

class HypyrIcons {
  static const IconData closeIcon = Icons.close_rounded;
  static const IconData phoneIcon = Icons.phone;
  static const IconData backIcon = Icons.chevron_left_rounded;
  static const IconData upIcon = Icons.keyboard_arrow_up_rounded;
  static const IconData infoIcon = Icons.info_rounded;
  static const Icon phone = const Icon(phoneIcon);
  static const Icon back = const Icon(backIcon);
  static const Icon close = const Icon(closeIcon);
  static const Icon up =
      const Icon(upIcon, color: AppColors.secondary, size: 16);
  static const Icon info = Icon(infoIcon, color: AppColors.white87);

  static const String spinnerLoc =
      'assets/spinner/moontree_spinner_v2_002_1_recolored.json';
  static const String adLoc = 'assets/images/';
  static const String profilePhotoLoc = 'assets/icons/comments/';
  static const String sendCircleLoc = 'assets/icons/comments/sendCircle.svg';
  static const String tallLineLoc =
      'assets/icons/comments/lineVerticalReply.svg';
  static const String replyLineLoc = 'assets/icons/comments/lineReplyTo.svg';
  static const String leftLoc = 'assets/icons/hypyr/chevron-left.svg';
  static const String navLoc = 'assets/images/nav.svg';
  static const String keyboardLoc = 'assets/icons/hypyr/keyboard.svg';
  static const String moveLoc = 'assets/icons/hypyr/move.svg';
  static const String stillLoc = 'assets/icons/hypyr/still.svg';
  static const String sectionsLoc = 'assets/icons/sections/';
  static const String googleLoc = 'assets/logo/google.svg';
  static const String instagramLoc = 'assets/logo/instagram.svg';
  static const String tiktokLoc = 'assets/logo/tiktok.svg';
  static const String heartLoc = 'assets/icons/comments/heart';
  static const String replyLoc = 'assets/icons/comments/reply.svg';
  static const String Home = 'assets/icons/comments/share.svg';
  static const String viewLoc = 'assets/images/view.svg';
  static const String profileLoc = 'assets/images/UNIMPLEMENTED.svg';
  static const String homeLoc = 'assets/images/UNIMPLEMENTED.svg';
  static const String emojiLoc = 'assets/images/UNIMPLEMENTED.svg';
  static const String editLoc = 'assets/images/UNIMPLEMENTED.svg';
  static const String hypyrPrestigeLoc = 'assets/icons/comments/hypyr';
  static const String hypyrLoc = 'assets/logo/hypyr.svg';
  static const String nanoLoc = 'assets/logo/nano.svg';
  static const String nanoOrbLoc = 'assets/logo/nano-orb.svg';
  static const String hypyrInvertWhiteLoc =
      'assets/logo/hypyr-invert-white.svg';
  static const String chevUpUpLoc = 'assets/icons/hypyr/chevron-up-two.svg';
  static const String toolFlipLoc = 'assets/icons/tools/flip.svg';
  static const String wonupLoc = 'assets/logo/wonup.svg';
  static const String wonupFadedLoc = 'assets/logo/wonup_faded.svg';
  static const String wonupToastLoc = 'assets/logo/wonup_toast.svg';
  static const String wonupOrbLoc = 'assets/logo/wonup_orb.svg';
  static const String wonupSmallOrbLoc = 'assets/logo/wonup_small_orb.svg';
  static const String wonupGreyOrbLoc = 'assets/logo/wonup_grey_orb.svg';
  static const String shareDarkLoc = 'assets/icons/hypyr/share-dark.svg';
  static const String shareLightLoc = 'assets/icons/hypyr/share-light.svg';
  static const String videoChatLoc = 'assets/icons/hypyr/arena-chat.svg';
  static const String joinLoc = 'assets/icons/hypyr/arena-join.svg';
  static const String homeAwardLoc = 'assets/icons/hypyr/home-award.svg';
  static const String homeReplyLoc = 'assets/icons/hypyr/home-reply.svg';
  static const String blastOffLocSVG =
      'assets/images/blast-off.svg'; // too complicated to render
  static const String blastOffLoc = 'assets/images/blast-off.png';
  static const String socialsLoc = 'assets/images/socials.svg';
  static const String profileOrbLoc = 'assets/icons/hypyr/profile-orb.svg';
  static const String homeLogoLoc = 'assets/icons/hypyr/logo-home.svg';
  static const String vsLogoLoc = 'assets/icons/hypyr/vs-logo.svg';
  static const String shareHomeLoc = 'assets/icons/hypyr/share.svg';
  static const String profileVsLoc = 'assets/icons/hypyr/vs-logo-profile.svg';

  static SvgPicture svgPicture({
    required String loc,
    BoxFit? fit,
    double? height,
    double? width,
  }) =>
      SvgPicture.asset(
        loc,
        height: height,
        width: width,
        fit: fit ?? BoxFit.fitHeight,
      );

  static SvgPicture tallLine({ColorFilter? colorFilter}) => SvgPicture.asset(
        tallLineLoc,
        fit: BoxFit.fitHeight,
        colorFilter: colorFilter,
      );

  static SvgPicture get nano => SvgPicture.asset(
        nanoLoc,
        //width: 24,
        //height: 204,
        //fit: BoxFit.contain,
        //alignment : Alignment.top,
      );
  static SvgPicture get nanoOrb => SvgPicture.asset(nanoOrbLoc);
  static SvgPicture get replyLine => SvgPicture.asset(replyLineLoc);
  static SvgPicture get left => SvgPicture.asset(leftLoc);
  static SvgPicture get reply => SvgPicture.asset(replyLoc);
  static SvgPicture get share => SvgPicture.asset(Home);
  static SvgPicture get google => SvgPicture.asset(googleLoc);
  static SvgPicture get instagram => SvgPicture.asset(instagramLoc);
  static SvgPicture get tiktok => SvgPicture.asset(tiktokLoc);
  static SvgPicture get keyboard => SvgPicture.asset(keyboardLoc);
  static SvgPicture get move => SvgPicture.asset(moveLoc);
  static SvgPicture get still => SvgPicture.asset(stillLoc);
  static SvgPicture get view => SvgPicture.asset(viewLoc);
  static SvgPicture get hypyr => SvgPicture.asset(hypyrLoc);
  static SvgPicture get hypyrInvertWhite =>
      SvgPicture.asset(hypyrInvertWhiteLoc);
  static SvgPicture get chevUpUp => SvgPicture.asset(chevUpUpLoc);
  static SvgPicture get nav => SvgPicture.asset(
        navLoc,
        fit: BoxFit.fill,
      );
  static SvgPicture hypyrPrestige(String prestige) =>
      SvgPicture.asset('${hypyrPrestigeLoc}${prestige}.svg');
  static SvgPicture heart(bool active) =>
      SvgPicture.asset('${heartLoc}${active ? 'Active' : ''}.svg');

  static SvgPicture profile(bool active) => SvgPicture.asset(profileLoc);
  static SvgPicture home(bool active) => SvgPicture.asset(homeLoc);
  static SvgPicture emoji(bool active) => SvgPicture.asset(emojiLoc);
  static SvgPicture edit(bool active) => SvgPicture.asset(editLoc);

  /* images */

  static Image ad(String ad) => Image.asset('${adLoc}${ad}.jpg');
  static Image pngSticker(String name) =>
      Image.asset('assets/assets/stills/png/transparent/${name}.png');
  static Image pngEmoji(String hexcode) =>
      Image.asset('assets/assets/stills/emoji/${hexcode}.png');
  static SvgPicture svgSticker(String name) =>
      SvgPicture.asset('assets/assets/stills/vectors/transparent/${name}.svg');
  static Image profilePhoto(
    String photo, {
    double? height = 24,
    double? width = 24,
    BoxFit? fit,
  }) =>
      Image.asset(
        '${profilePhotoLoc}${photo}.png',
        height: height,
        width: width,
        filterQuality: FilterQuality.high,
        scale: 1 / 3,
        cacheWidth: 72,
        cacheHeight: 72,
        fit: fit,
      );
}
