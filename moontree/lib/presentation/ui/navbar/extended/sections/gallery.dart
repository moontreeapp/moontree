import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_device_media/device_media.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:moontree/cubits/navbar/gallery/cubit.dart';
import 'package:moontree/utils/random.dart';
import 'package:moontree/presentation/widgets/animations/fading.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/services/services.dart' show screen;
import 'package:moontree/presentation/utils/animation.dart' as animation;

class GallerySection extends StatefulWidget {
  final void Function() exit;
  const GallerySection({super.key, required this.exit});

  @override
  _GallerySectionState createState() => _GallerySectionState();
}

class _GallerySectionState extends State<GallerySection> {
  final double width = screen.width - 16;
  final double height = screen.navbar.maxHeight - 64;
  final int gridHeight = 4;
  bool grid = false;
  bool built = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void returnHome({int? index}) {
    if (index != null) {
      cubits.emojiCarousel.update(selectedIndex: index + 1);
      cubits.emojiCarousel.state.scroll
          ?.jumpTo(screen.navbar.itemWidth * (index + 1));
      cubits.emojiCarousel.state.scroll?.animateTo(
          screen.navbar.itemWidth * (index + 1) + 1,
          duration: animation.slideDuration,
          curve: Curves.easeIn);
    }
    cubits.navbar.mid();
  }

  void chooseImage() {
    DeviceMediaServiceImpl()
        .openPickImage(DeviceMediaSource.gallery,
            needCompress: false, needCrop: false)
        .then((String? value) => cubits.gallery.update(path: value ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    if (!built) {
      if (cubits.gallery.state.path == '') {
        WidgetsBinding.instance.addPostFrameCallback((_) => chooseImage());
      }
      built = true;
    }
    return FadeIn(
        duration: animation.fadeDuration,
        delay: const Duration(milliseconds: 100),
        refade: false,
        child: BlocBuilder<GalleryCubit, GalleryState>(
            buildWhen: (previous, current) => previous.path != current.path,
            builder: (context, state) => Column(children: [
                  GestureDetector(
                      // todo put icon in cubit, pull icon to nav.
                      onTap: () {
                        if (state.path == '') {
                          chooseImage();
                        } else {
                          returnHome();
                        }
                      },
                      onLongPress: () {
                        chooseImage();
                      },
                      child: ChosenImageView(
                          onTap: chooseImage,
                          height: height,
                          width: screen.width,
                          path: state.path)),
                ])));
  }
}

class ChosenImageView extends StatelessWidget {
  final double height;
  final double width;
  final String path;
  final void Function() onTap;

  ChosenImageView({
    required this.height,
    required this.width,
    required this.path,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      child: Container(
          //height: height * .618,
          //width: screen.width * .618,
          padding: EdgeInsets.all(16),
          child: path != ''
              ? Stack(alignment: Alignment.topRight, children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(File(path))),
                  GestureDetector(
                      onTap: onTap,
                      child: Container(
                          //color: AppColors.offTransparent,
                          color: Colors.transparent,
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.change_circle_outlined,
                              color: Colors.white70))),
                  //ClipRRect(
                  //    borderRadius: BorderRadius.circular(16),
                  //    child: Container(
                  //      alignment: Alignment.center,
                  //      decoration: BoxDecoration(
                  //        image: DecorationImage(
                  //          image: FileImage(
                  //              File(cubits.gallery.state.path)),
                  //          fit: BoxFit.cover,
                  //        ),
                  //      ),
                  //    ))
                ])
              : [
                  Icon(Hicons.image_2_bold,
                      color: Colors.white24, size: screen.width * .618),
                  Icon(Icons.add_circle_outline_rounded,
                      color: Colors.white24, size: screen.width * .618)
                ].random)
      //Text('Long Press', style: TextStyle(color: Colors.white)),
      );
}
