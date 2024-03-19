/// contains the type and widget for flickagles
/// specials, say and gallery are flickables too
/// indicator is on flickable
/// shadow is on indicator
/// that's it.
///
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:moontree/cubits/cubits.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/presentation/components/icons.dart';
import 'package:moontree/presentation/layers/navbar/components/carousel.dart';
import 'package:moontree/services/services.dart' show screen;
import 'package:moontree/presentation/theme/colors.dart';
import 'package:moontree/presentation/utils/animation.dart';
import 'package:moontree/presentation/widgets/animations/fading.dart';
import 'package:moontree/presentation/widgets/animations/glowing.dart';

class Sticker extends StatelessWidget {
  final String name;
  final bool chosen;
  const Sticker({super.key, required this.name, required this.chosen});

  @override
  Widget build(BuildContext context) {
    if (chosen) {
      return Stack(alignment: Alignment.center, children: [
        Container(
            width: screen.navbar.itemWidth,
            alignment: Alignment.center,
            child: Container(
              width: screen.navbar.itemHeight,
              height: screen.navbar.itemHeight,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black60,
                    spreadRadius: 1, // Spread radius
                    blurRadius: 3, // Blur radius
                    offset: Offset(0, 0), // Changes position of shadow
                  ),
                ],
              ),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  image: DecorationImage(
                    image: HypyrIcons.pngEmoji(name).image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            )),
        FadeIn(child: CenterIcon(size: screen.navbar.carouselHeight - 8)),
      ]);
    }
    //return Container(
    //    width: screen.navbar.itemWidth,
    //    // give shadow,
    //    alignment: Alignment.center,
    //    child: CircleImage(
    //        height: screen.navbar.itemHeight,
    //        width: screen.navbar.itemHeight,
    //        image: HypyrIcons.pngSticker(name).image));
    return Container(
        width: screen.navbar.itemWidth,
        alignment: Alignment.center,
        child: Container(
          width: screen.navbar.itemHeight,
          height: screen.navbar.itemHeight,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: AppColors.black60,
          ),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              image: DecorationImage(
                image: HypyrIcons.pngEmoji(name).image,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ));
  }
}

class SaySticker extends StatelessWidget {
  final int index;
  const SaySticker({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmojiCarouselCubit, EmojiCarouselState>(
        buildWhen: (previous, current) =>
            previous.selectedIndex != current.selectedIndex ||
            previous.indicatorStatus != current.indicatorStatus,
        builder: (context, state) {
          final chosen = state.selectedIndex == index;
          Color? color;
          //if (!full) {
          //  if (chosen) {
          //    color = Colors.white60;
          //  } else {
          //    //color = null;
          //    color = Colors.white38;
          //  }
          //} else {
          //  if (chosen) {
          //    color = Colors.white;
          //  } else {
          //    color = Colors.white70;
          //  }
          //}

          color = Colors.white;
          if (chosen) {
            return Stack(alignment: Alignment.center, children: [
              Container(
                  width: screen.navbar.itemWidth,
                  height: screen.navbar.carouselHeight,
                  alignment: Alignment.center,
                  child: Container(
                    width: screen.navbar.itemHeight,
                    height: screen.navbar.itemHeight,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(bottom: 4.5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black60,
                            spreadRadius: 1, // Spread radius
                            blurRadius: 3, // Blur radius
                            offset: Offset(0, 0), // Changes position of shadow
                          ),
                        ]),
                    child: Icon(Hicons.keyboard_bold,
                        color: color, size: screen.navbar.itemHeight - 18),
                  )),
              FadeIn(
                  child: state.indicatorStatus == IndicatorStatus.failure
                      ? GlowingIndicator(
                          size: screen.navbar.carouselHeight - 8,
                          duration: fadeDuration,
                        )
                      : CenterIcon(size: screen.navbar.carouselHeight - 8)),
            ]);
          }
          // Container(
          //   width: width,
          //   height: height,
          //   alignment: Alignment.center,
          //   child: Container(
          //     width: height,
          //     alignment: Alignment.center,
          //     padding: const EdgeInsets.only(bottom: 4.5),
          //     decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(100), color: AppColors.black60),
          //     child: Icon(
          //       iconData!,
          //       color: color ?? AppColors.white87,
          //       size: iconSize,
          //     ),
          //   ));
          return Container(
              width: screen.navbar.itemWidth,
              height: screen.navbar.carouselHeight,
              alignment: Alignment.center,
              child: Container(
                width: screen.navbar.itemHeight,
                height: screen.navbar.itemHeight,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 4.5),
                decoration: BoxDecoration(
                  color: AppColors.black60,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(Hicons.keyboard_bold,
                    color: color, size: screen.navbar.itemHeight - 18),
              ));
        });
  }
}

class GallerySticker extends StatelessWidget {
  final int index;
  final String? path;
  const GallerySticker({super.key, required this.index, this.path});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmojiCarouselCubit, EmojiCarouselState>(
        buildWhen: (previous, current) =>
            previous.selectedIndex != current.selectedIndex ||
            previous.indicatorStatus != current.indicatorStatus,
        builder: (context, state) {
          if (state.selectedIndex == index) {
            return Stack(alignment: Alignment.center, children: [
              Container(
                  width: screen.navbar.itemWidth,
                  height: screen.navbar.carouselHeight,
                  alignment: Alignment.center,
                  child: Container(
                    width: screen.navbar.itemHeight,
                    height: screen.navbar.itemHeight,
                    alignment: Alignment.center,
                    padding: cubits.gallery.state.path == ''
                        ? const EdgeInsets.only(bottom: 4.5)
                        : null,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black60,
                            spreadRadius: 1, // Spread radius
                            blurRadius: 3, // Blur radius
                            offset: Offset(0, 0), // Changes position of shadow
                          ),
                        ]),
                    child: cubits.gallery.state.path == ''
                        ? Icon(Hicons.image_2_bold,
                            color: Colors.white54,
                            size: screen.navbar.itemHeight - 18)
                        //: Container(
                        //  width: screen.navbar.itemWidth,
                        //  alignment: Alignment.center,
                        //  child: Container(
                        //      width: screen.navbar.itemHeight,
                        //      height: screen.navbar.itemHeight,
                        //      alignment: Alignment.center,
                        //      padding: const EdgeInsets.only(left: 12, right: 12),
                        //      decoration: BoxDecoration(
                        //        borderRadius: BorderRadius.circular(100),
                        //        color: AppColors.black60,
                        //      ),
                        //      child: Image.file(File(cubits.gallery.state.path))))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: FileImage(
                                      File(cubits.gallery.state.path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )),
                  )),
              FadeIn(
                  child: state.indicatorStatus == IndicatorStatus.failure
                      ? GlowingIndicator(
                          size: screen.navbar.carouselHeight - 8,
                          duration: fadeDuration,
                        )
                      : CenterIcon(size: screen.navbar.carouselHeight - 8)),
            ]);
          }
          return Container(
              width: screen.navbar.itemWidth,
              height: screen.navbar.carouselHeight,
              alignment: Alignment.center,
              child: Container(
                width: screen.navbar.itemHeight,
                height: screen.navbar.itemHeight,
                alignment: Alignment.center,
                padding: cubits.gallery.state.path == ''
                    ? const EdgeInsets.only(bottom: 4.5)
                    : null,
                decoration: BoxDecoration(
                  color: AppColors.black60,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: cubits.gallery.state.path == ''
                    ? Icon(Hicons.image_2_bold,
                        color: Colors.white38,
                        size: screen.navbar.itemHeight - 18)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(cubits.gallery.state.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )),
              ));
        });
  }
}

class CameraPictureButton extends StatelessWidget {
  final bool chosen;
  final Color color;
  const CameraPictureButton({
    super.key,
    required this.chosen,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (chosen) {
      return Stack(alignment: Alignment.center, children: [
        Container(
            alignment: Alignment.center,
            child: Container(
              width: screen.navbar.itemHeight,
              height: screen.navbar.itemHeight,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black60,
                    spreadRadius: 1, // Spread radius
                    blurRadius: 3, // Blur radius
                    offset: Offset(0, 0), // Changes position of shadow
                  ),
                ],
              ),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            )),
        FadeIn(child: CenterIcon(size: screen.navbar.carouselHeight - 8)),
      ]);
    }
    //return Container(
    //    width: screen.navbar.itemWidth,
    //    // give shadow,
    //    alignment: Alignment.center,
    //    child: CircleImage(
    //        height: screen.navbar.itemHeight,
    //        width: screen.navbar.itemHeight,
    //        image: HypyrIcons.pngSticker(name).image));
    return Container(
        width: screen.navbar.itemWidth,
        alignment: Alignment.center,
        child: Container(
          width: screen.navbar.itemHeight,
          height: screen.navbar.itemHeight,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: AppColors.black60,
          ),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ));
  }
}

class StarButton extends StatelessWidget {
  final bool chosen;
  final int number;
  const StarButton({
    super.key,
    required this.chosen,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    final ret = Container(
        width: screen.navbar.itemWidth,
        alignment: Alignment.center,
        child: Container(
          width: screen.navbar.itemHeight + 8,
          height: screen.navbar.itemHeight + 8,
          alignment: Alignment.center,
          child: Stack(children: [
            //Container(
            //    width: screen.navbar.itemHeight + 8,
            //    height: screen.navbar.itemHeight + 8,
            //    alignment: Alignment.center,
            //    padding: EdgeInsets.only(bottom: 16),
            //    child: Icon(
            //      Icons.star_rate_rounded,
            //      size: screen.navbar.itemHeight + 8,
            //      color: AppColors.primary,
            //    )),
            Container(
                width: screen.navbar.itemHeight + 8,
                height: screen.navbar.itemHeight + 8,
                alignment: Alignment.center,
                //padding: EdgeInsets.only(top: 4),
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  '$number',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 40, color: Colors.white),
                )),
          ]),
        ));
    if (chosen) {
      return Stack(alignment: Alignment.center, children: [
        ret,
        FadeIn(child: CenterIcon(size: screen.navbar.carouselHeight - 8)),
      ]);
    }
    return ret;
  }
}
