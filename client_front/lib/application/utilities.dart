import 'package:wallet_utils/wallet_utils.dart' show satsPerCoin;

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

class TransactionComponents {
  final int coinInput;
  final int fee;
  // assumes we're only sending to 1 address
  final bool targetAddressAmountVerified;
  // should be inputs - fee - target
  final bool changeAddressAmountVerified;
  const TransactionComponents({
    required this.coinInput,
    required this.fee,
    required this.targetAddressAmountVerified,
    required this.changeAddressAmountVerified,
  });

  bool get feeSanityCheck => fee < 2 * satsPerCoin;
}
