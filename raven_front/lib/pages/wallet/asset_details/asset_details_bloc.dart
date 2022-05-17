class AssetDetailsBloc {
  AssetDetailsBloc._() {}
  factory AssetDetailsBloc.instance() {
    return _instance ??= AssetDetailsBloc._();
  }
  static AssetDetailsBloc? _instance;

  double getOpacityFromController(
      double controllerValue, double minHeightFactor) {
    double opacity = 1;
    if (controllerValue >= 0.9)
      opacity = 0;
    else if (controllerValue <= minHeightFactor)
      opacity = 1;
    else
      opacity = (0.9 - controllerValue) * 5;
    return opacity;
  }
}
