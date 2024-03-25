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

mixin HeightCubitMixin {
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

mixin UpdateMixin<T> {
  String get key;
  void reset();
  void update();
  void setState(T state);
}

mixin SectionMixin<T> {
  void hide();
}

mixin UpdateSectionMixin<T> implements UpdateMixin<T>, SectionMixin<T> {}
