import 'package:raven_back/utilities/utilities.dart';

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
    if (length > 15 || contains('.')) {
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
      var num = split('.');
      var whole = num.first;
      var remainder = num.sublist(1).join('');
      if (whole.length > 15 || remainder.length > 8) {
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
    var amount;
    if (isInt) {
      amount = int.parse(this);
    } else if (isDouble) {
      amount = double.parse(this);
    }
    return amount;
  }

  num? toRVNAmount() {
    var amount;
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
