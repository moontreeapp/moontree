import 'package:flutter/material.dart';
import 'package:moontree/presentation/components/icons.dart';
import 'package:moontree/presentation/widgets/animations/fading.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/services/services.dart' show screen;
import 'package:moontree/presentation/utils/animation.dart' as animation;

class EditSection extends StatefulWidget {
  final void Function() exit;
  final int? index;
  const EditSection({super.key, required this.exit, this.index});

  @override
  _EditSectionState createState() => _EditSectionState();
}

class _EditSectionState extends State<EditSection> {
  final double width = screen.width - 16;
  final double height = screen.navbar.maxHeight - 64 - 16 - 100;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void returnHome() {
    if (widget.index != null) {
      updateIndex(widget.index!);
    }
    dropNav();
  }

  void dropNav() {
    cubits.navbar.mid();
  }

  void updateIndex(int index) {
    if (cubits.emojiCarousel.indexOnStart) {
      // todo: show image of this thing on last index (7)
      return;
    }
    if (cubits.emojiCarousel.indexOnEnd) {
      // todo: show image of this thing on last index (7)
      return;
    }
    int? existingIndex = cubits.emojiCarousel.getFlickableIndex(index);
    if (existingIndex != null) {
      cubits.emojiCarousel.update(selectedIndex: existingIndex);
      cubits.emojiCarousel.state.scroll
          ?.jumpTo(screen.navbar.itemWidth * (existingIndex));
      cubits.emojiCarousel.state.scroll?.animateTo(
          screen.navbar.itemWidth * (existingIndex) + 1,
          duration: animation.slideDuration,
          curve: Curves.easeIn);
    } else {
      cubits.emojiCarousel.insertFlickable(index: index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeIn(
        duration: animation.fadeDuration,
        delay: const Duration(milliseconds: 100),
        refade: false,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          //Container(
          //    height: 100,
          //    alignment: Alignment.bottomCenter,
          //    padding:
          //        EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
          //    child: Row(
          //        mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //        children: [
          //          Container(
          //              alignment: Alignment.center,
          //              width: screen.width - 32 - 32 - 16,
          //              color: Colors.grey,
          //              child: Text('Controls')),
          //        ])),
          SizedBox(height: 8),
          SizedBox(height: 48),
          GestureDetector(
              onTap: returnHome,
              onLongPress: widget.exit,
              child: Container(
                  width: screen.width - 48,
                  height: height,
                  alignment: Alignment.center,
                  child: HypyrIcons.pngEmoji(widget.index == null
                      ? cubits.emojiCarousel.indexOnSticker
                          ? cubits
                              .emojiCarousel
                              .state
                              .flickables[
                                  cubits.emojiCarousel.state.selectedIndex]
                              .hexcode
                          : cubits.emojiCarousel.state.flickables[1].hexcode
                      : cubits.emojiCarousel.state.showables[widget.index!]
                          .hexcode))),
          SizedBox(height: 8),
        ]));
  }
}
