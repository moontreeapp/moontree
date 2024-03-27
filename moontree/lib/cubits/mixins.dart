mixin HideMixin<T> {
  void hide();
}

mixin UpdateMixin<T> {
  String get key;
  void reset();
  void update();
  void setState(T state);
}

mixin DisposedMixin {
  void disposed();
  bool isDisposed();
}

mixin UpdateHideMixin<T> implements UpdateMixin<T>, HideMixin {}
