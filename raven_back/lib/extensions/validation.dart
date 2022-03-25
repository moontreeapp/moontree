import 'package:raven_back/utilities/utilities.dart';

extension TypeValidationNumericExtension on String {
  bool get isInt {
    if (length > 15) {
      return false;
    }
    try {
      int.parse(this);
      return true;
    } catch (e) {
      return false;
    }
  }
}

extension AmountValidationNumericExtension on num {
  bool get isRVNAmount => utils.validate.isRVNAmount(this);
}

extension StringValidationExtension on String {
  bool get isIpfs => utils.validate.isIpfs(this);
  bool get isAddressRVN => utils.validate.isAddressRVN(this);
  bool get isAddressRVNt => utils.validate.isAddressRVNt(this);
  bool get isTxIdRVN => utils.validate.isTxIdRVN(this);
  bool get isTxIdFlow => utils.validate.isTxIdFlow(this);
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
  bool get isAssetMemo => utils.validate.isAssetMemo(this);
}
