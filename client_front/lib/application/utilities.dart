enum FrontContainerHeight {
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
  void setHeightTo({required FrontContainerHeight height}) {
    switch (height) {
      case FrontContainerHeight.same:
        return;
      case FrontContainerHeight.max:
        return max();
      case FrontContainerHeight.mid:
        return mid();
      case FrontContainerHeight.min:
        return min();
      case FrontContainerHeight.hidden:
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
