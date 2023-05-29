import 'package:wallet_utils/wallet_utils.dart' show coinsPerChain, satsPerCoin;

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

/// coin number as string to sats as int
/// maximum int:  9,223,372,036,854,775,807
/// satsPerChain: 2,100,000,000,000,000,000
/// 21,000,000,000
int? asCoinToSats(String? text) {
  if (text == null) {
    return null;
  }
  text = text.replaceAll(',', '').replaceAll(' ', '').replaceAll('-', '');
  if (RegExp(r'^(\d*(\.\d{0,8})?|\.\d{0,8})$').hasMatch(text)) {
    if (text.contains('.')) {
      final leftRight = text.split('.');
      final left = leftRight[0];
      // check to see if the left alone is too large before checking stuff in
      // the range of possibly BigInt
      if (left != '' && int.parse(left) > coinsPerChain) {
        return null;
      }
      final right = leftRight[1]; // only 1 period due to regex above.
      final value = int.parse(left + right + ('0' * (8 - right.length)));
      if (value > int.parse(coinsPerChain.toString() + ('0' * 8))) {
        return null;
      }
      return value;
    }
    if (text != '' && int.parse(text) > coinsPerChain) {
      return null; // too large
    }
    return int.parse(text + ('0' * 8));
  }
  return null;
}
