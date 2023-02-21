enum PageContainerHeight {
  max,
  mid,
  min,
  hidden,
  same,
}

enum PageContainer {
  front,
  back,
  extra,
}

abstract class ViewCubitMixin {
  void show() {}
  void hide() {}
}

abstract class HeightCubitMixin {
  void setHeightTo({required PageContainerHeight height}) {
    switch (height) {
      case PageContainerHeight.same:
        return;
      case PageContainerHeight.max:
        return max();
      case PageContainerHeight.mid:
        return mid();
      case PageContainerHeight.min:
        return min();
      case PageContainerHeight.hidden:
        return hidden();
      default:
        return mid();
    }
  }

  void max() {}
  void mid() {}
  void min() {}
  void hidden() {}
}
