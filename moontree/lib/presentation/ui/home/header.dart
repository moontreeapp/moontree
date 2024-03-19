import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/home/feed/cubit.dart';
import 'package:moontree/domain/concepts/side.dart';
import 'package:moontree/presentation/components/icons.dart';
import 'package:moontree/presentation/layers/profile/components/content/picture.dart';
import 'package:moontree/presentation/services/services.dart';
import 'package:moontree/presentation/theme/colors.dart';
import 'package:moontree/presentation/theme/extensions.dart';
import 'package:moontree/presentation/widgets/animations/animations.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) => Container(
      height: 56,
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 3),
          child: HypyrIcons.svgPicture(
            loc: HypyrIcons.homeLogoLoc,
            height: 30,
            width: 30,
          ),
        ),
        Text('challenge name',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.h2!.copyWith(
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 1.0,
                  color: Color.fromRGBO(0, 0, 0, 0.50),
                ),
              ],
            )),
        const SizedBox(height: 30, width: 30)
      ]));
}

class VsProfile extends StatelessWidget {
  final bool isChampion;
  const VsProfile({super.key, required this.isChampion});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<HomeFeedCubit, HomeFeedState>(
          buildWhen: (HomeFeedState previous, HomeFeedState current) =>
              isChampion
                  ? previous.champion.uid != current.champion.uid
                  : previous.challenger.uid != current.challenger.uid,
          builder: (BuildContext context, HomeFeedState state) {
            late HomeVideoMetadata metadata;
            if (isChampion) {
              if (state.champion.metadata is HomeVideoMetadata) {
                metadata = state.champion.metadata as HomeVideoMetadata;
              } else {
                return const SizedBox.shrink();
              }
            } else {
              if (state.challenger.metadata is HomeVideoMetadata) {
                metadata = state.challenger.metadata as HomeVideoMetadata;
              } else {
                return const SizedBox.shrink();
              }
            }
            return RawProfilePicture(
              size: 56,
              shadow: true,
              photo: metadata.user.photo,
            );
          });
}

class VsPlusOne extends StatelessWidget {
  final bool isChampion;
  const VsPlusOne({super.key, required this.isChampion});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<HomeFeedCubit, HomeFeedState>(
          buildWhen: (HomeFeedState previous, HomeFeedState current) =>
              previous.champion.uid != current.champion.uid ||
              previous.challenger.uid != current.challenger.uid,
          builder: (BuildContext context, HomeFeedState state) {
            if (isChampion) {
              if (state.prior?.champion.uid == state.champion.uid &&
                  state.prior?.challenger.uid != state.challenger.uid) {
                return FadeOut(
                    refade: true,
                    child: SlideSide(
                        side: Side.top,
                        enter: false,
                        child: SizedBox(
                            width: 56,
                            height: 56,
                            child: Text('+1',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .h2!
                                    .copyWith(color: Colors.white, shadows: [
                                  Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 1.0,
                                      color: Color.fromRGBO(0, 0, 0, 0.50))
                                ])))));
              }
            } else {
              if (state.prior?.champion.uid != state.champion.uid &&
                  state.prior?.challenger.uid == state.challenger.uid) {
                return FadeOut(
                    refade: true,
                    child: SlideSide(
                        side: Side.bottom,
                        enter: false,
                        child: SizedBox(
                            width: 56,
                            height: 56,
                            child: Text('+1',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .h2!
                                    .copyWith(color: Colors.white, shadows: [
                                  Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 1.0,
                                      color: Color.fromRGBO(0, 0, 0, 0.50))
                                ])))));
              }
            }
            return const SizedBox(width: 56);
          });
}

class VsSection extends StatelessWidget {
  const VsSection({super.key});

  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
            height: 32,
            width: 191,
            alignment: Alignment.center,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  VsPlusOne(isChampion: true),
                  const SizedBox(width: 56),
                  const SizedBox(width: 56),
                ])),
        Stack(alignment: Alignment.center, children: [
          Column(
            children: [
              Container(
                  height: 1,
                  width: screen.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[
                        AppColors.black38,
                        AppColors.black38,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        AppColors.black38,
                        AppColors.black38,
                      ],
                    ),
                  )),
              const SizedBox(height: 2),
              Container(
                  height: 1,
                  width: screen.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[
                        AppColors.black38,
                        AppColors.black38,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        AppColors.black38,
                        AppColors.black38,
                      ],
                    ),
                  )),
            ],
          ),
          Container(
              height: 2,
              width: screen.width,
              decoration: BoxDecoration(
                //boxShadow: [
                //  BoxShadow(
                //      color: AppColors.black38,
                //      spreadRadius: 1, // Spread radius
                //      blurRadius: 1, // Blur radius
                //      offset: Offset(0, 0), // Changes position of shadow
                //      blurStyle: BlurStyle.normal),
                //],
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    AppColors.white,
                    AppColors.white.withOpacity(.5),
                    Colors.transparent,
                    AppColors.white.withOpacity(.5),
                    AppColors.white,
                  ],
                ),
              )),
          Container(
              height: 64,
              width: 191,
              alignment: Alignment.center,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    VsProfile(isChampion: true),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 3),
                      child: HypyrIcons.svgPicture(
                        loc: HypyrIcons.vsLogoLoc,
                        height: 56,
                        width: 56,
                      ),
                    ),
                    VsProfile(isChampion: false),
                  ]))
        ]),
        Container(
            height: 32,
            width: 191,
            alignment: Alignment.center,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 56),
                  const SizedBox(width: 56),
                  VsPlusOne(isChampion: false),
                ])),
      ]);
}

/// END SUGGESTIONS ///////////////////////////////////////////////////////////
class HomeOverlay extends StatelessWidget {
  const HomeOverlay({super.key});

  @override
  Widget build(BuildContext context) => Container(
      height: screen.app.displayHeight,
      alignment: Alignment.topCenter,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        HomeHeader(),
        VsSection(),
        SizedBox(height: 56),
      ]));
}
