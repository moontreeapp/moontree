import 'package:ravencoin_back/utilities/utilities.dart';

extension AmountValidationNumericExtension on num {
  bool get isRVNAmount => utils.validate.isRVNAmount(this);
}

extension AmountValidationIntExtension on int {
  bool get isRVNAmount => utils.validate.isRVNAmount(this);
}

extension AmountValidationDoubleExtension on double {
  bool get isRVNAmount => utils.validate.isRVNAmount(this);
}

extension RVNNumericValidationExtension on String {
  bool get isInt {
    if (length > 19 || contains('.')) {
      return false;
    }
    try {
      int.parse(this);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool get isDouble {
    if (contains('.')) {
      final List<String> num = split('.');
      final String whole = num.first;
      final String remainder = num.sublist(1).join();
      if ((whole.length > 14 && whole.contains(',')) ||
          (whole.length > 11 && !whole.contains(',')) ||
          remainder.length > 8) {
        return false;
      }
    }
    try {
      double.parse(this);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool get isNumeric => isInt || isDouble;
  num? toNum() {
    num? amount;
    if (isInt) {
      amount = int.parse(this);
    } else if (isDouble) {
      amount = double.parse(this);
    }
    return amount;
  }

  num? toRVNAmount() {
    num? amount;
    if (isInt) {
      amount = int.parse(this);
    } else if (isDouble) {
      amount = double.parse(this);
    }
    if (amount == null) {
      return null;
    }
    if (amount.isRVNAmount) {
      return amount;
    }
    return null;
  }
}

extension StringValidationExtension on String {
  bool get isIpfs => utils.validate.isIpfs(this);
  bool get isAddressRVN => utils.validate.isAddressRVN(this);
  bool get isAddressRVNt => utils.validate.isAddressRVNt(this);
  bool get isAddressEVR => utils.validate.isAddressEVR(this);
  bool get isAddressEVRt => utils.validate.isAddressEVRt(this);
  bool get isTxIdRVN => utils.validate.isTxIdRVN(this);
  bool get isAdmin => utils.validate.isAdmin(this);
  bool get isAssetPath => utils.validate.isAssetPath(this);
  bool get isMainAsset => utils.validate.isMainAsset(this);
  bool get isSubAsset => utils.validate.isSubAsset(this);
  bool get isNFT => utils.validate.isNFT(this);
  bool get isChannel => utils.validate.isChannel(this);
  bool get isQualifier => utils.validate.isQualifier(this);
  bool get isSubQualifier => utils.validate.isSubQualifier(this);
  bool get isQualifierString => utils.validate.isQualifierString(this);
  bool get isRestricted => utils.validate.isRestricted(this);
  bool get isMemo => utils.validate.isMemo(this);
  bool get isAssetData => utils.validate.isAssetData(this);
}
