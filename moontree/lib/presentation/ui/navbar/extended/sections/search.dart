import 'package:flutter/material.dart';
import 'package:moontree/presentation/components/icons.dart';
import 'package:moontree/presentation/widgets/animations/fading.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/services/services.dart' show screen;
import 'package:moontree/presentation/utils/animation.dart' as animation;

/// contains search and view of images
class SearchSection extends StatefulWidget {
  final void Function() exit;
  const SearchSection({super.key, required this.exit});

  @override
  _SearchSectionState createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  final double width = screen.width - 16;
  final double height = screen.navbar.maxHeight - 64 - 16;
  final FocusNode searchFocus = FocusNode();
  final TextEditingController search = TextEditingController();
  final int gridHeight = 5;
  int? editIndex;

  @override
  void initState() {
    super.initState();
    searchFocus.addListener(reload);
  }

  void reload() => setState(() {
        if (!cubits.navbar.state.edit && !searchFocus.hasFocus) {
          search.text = '';
        }
      });

  @override
  void dispose() {
    searchFocus.removeListener(reload);
    search.dispose();
    searchFocus.dispose();
    if (this.mounted) {
      try {} catch (e) {
        print('listScroll.dispose() failed: $e');
      }
    }
    super.dispose();
  }

  double calculateInitialGridOffset(double index) =>
      (height / gridHeight) * (index / gridHeight).floor();

  void returnHome([int? index]) {
    if (index != null) {
      updateIndex(index);
    }
    dropNav();
  }

  void dropNav() {
    cubits.navbar.mid();
  }

  void updateIndex(int index) {
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
        child: Column(
          children: [
            Container(
                width: width,
                height: height,
                alignment: Alignment.center,
                child: Stack(children: [
                  GridView.builder(
                    controller: ScrollController(
                      initialScrollOffset: calculateInitialGridOffset(
                          (cubits.emojiCarousel.namedIndex ?? 0).toDouble()),
                      //cubits.navbar.state.selectedIndex - 1),
                    ),
                    scrollDirection: Axis.horizontal,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridHeight,
                    ),
                    itemCount: cubits.emojiCarousel.state.showables.length,
                    itemBuilder: (context, index) {
                      final item = cubits.emojiCarousel.state.showables[index];
                      return GestureDetector(
                          onTap: () => returnHome(index),
                          child: ItemView(
                              selected:
                                  (cubits.emojiCarousel.namedIndex ?? 0) ==
                                      index,
                              name: item.hexcode,
                              height: (height / gridHeight)));
                    },
                  ),
                ])),
          ],
        ));
  }
}

class ItemView extends StatelessWidget {
  final double height;
  final String name;
  final bool selected;
  const ItemView({
    super.key,
    required this.height,
    required this.name,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) => selected
      ? Column(children: [
          Container(
            height: height - 3,
            padding:
                const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 2),
            child: HypyrIcons.pngEmoji(name),
          ),
          Container(
            height: 3,
            width: (height - 5) * .618 * .618 * .618,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.white60),
          )
        ])
      : Container(
          padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
          child: HypyrIcons.pngEmoji(name),
        );
}
