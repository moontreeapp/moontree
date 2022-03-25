import 'package:ravencoin_wallet/src/address.dart' show Address;
import 'package:ravencoin_wallet/src/models/networks.dart' as networks;

// https://github.com/RavenProject/Ravencoin/blob/master/src/assets/assets.cpp
final int MAX_NAME_LENGTH = 30; // Without $, !
final int MAX_CHANNEL_NAME_LENGTH = 12;
final int MAX_VERIFIER_STRING = 80;

final RegExp ROOT_NAME_CHARACTERS = RegExp(r'^[A-Z0-9._]{3,}$');
final RegExp SUB_NAME_CHARACTERS = RegExp(r'^[A-Z0-9._]+$');
final RegExp UNIQUE_TAG_CHARACTERS = RegExp(r'^[-A-Za-z0-9@$%&*()[\]{}_.?:]+$');
final RegExp MSG_CHANNEL_TAG_CHARACTERS = RegExp(r'^[A-Za-z0-9_]+$');

final RegExp QUALIFIER_NAME_CHARACTERS = RegExp(r'#[A-Z0-9._]{3,}$');
final RegExp SUB_QUALIFIER_NAME_CHARACTERS = RegExp(r'#[A-Z0-9._]+$');
final RegExp RESTRICTED_NAME_CHARACTERS = RegExp(r'\$[A-Z0-9._]{3,}$');

final RegExp DOUBLE_PUNCTUATION = RegExp(r'^.*[._]{2,}.*$');
final RegExp LEADING_PUNCTUATION = RegExp(r'^[._].*$');
final RegExp TRAILING_PUNCTUATION = RegExp(r'^.*[._]$');
final RegExp QUALIFIER_LEADING_PUNCTUATION = RegExp(r'^[#\$][._].*$');
final RegExp QUALIFING_STRING_LOGIC_NO_PARENTHESIS =
    RegExp(r'^((!?[A-Z0-9._]{3,})|((!?[A-Z0-9._]{3,}[|&])+!?[A-Z0-9._]{3,}))$');
final RegExp EMPTY_PARENTHESIS = RegExp(r'\(\)');
final RegExp CHILD_ASSETS = RegExp(r'#|/|~');

final RegExp RAVEN_NAMES =
    RegExp(r'^RVN$|^RAVEN$|^RAVENCOIN$|^#RVN$|^#RAVEN$|^#RAVENCOIN$');

/// todo identify a ipfs hash correctly...
// https://ethereum.stackexchange.com/questions/17094/how-to-store-ipfs-hash-using-bytes32/17112#17112
// looks like we just need to consider hex strings or something...
bool isIpfs(String x) => x.contains(RegExp(
    r'^Qm[1-9A-HJ-NP-Za-km-z]{44}$|^b[A-Za-z2-7]{58}$|^B[A-Z2-7]{58}$|^z[1-9A-HJ-NP-Za-km-z]{48}$|^F[0-9A-F]{50}$'));

bool isAddressRVN(String x) => Address.validateAddress(x, networks.mainnet);
bool isAddressRVNt(String x) => Address.validateAddress(x, networks.testnet);
bool isTxIdRVN(String x) => x.contains(RegExp(r'^[0-9a-f]{64}$'));
// This is the raw hex that will be input into the chain as the associated IPFS
// Should be check as input as isTxIdRVN
bool isTxIdFlow(String x) => x.contains(RegExp(r'^5420[0-9a-f]{64}$'));
bool isAdmin(String x) =>
    x.isNotEmpty &&
    x[x.length - 1] == '!' &&
    isAssetPath(x.substring(0, x.length - 1));

bool isAssetPath(String x) {
  if (x.isEmpty) {
    return false;
  }
  var lengthAdds = 0;
  if (x[0] == '\$') {
    lengthAdds += 1;
  }
  if (x[x.length - 1] == '!') {
    lengthAdds += 1;
  }
  if (x.contains(CHILD_ASSETS)) {
    lengthAdds += 1;
  }
  if (x.length > 30 + lengthAdds) {
    return false;
  }
  if (x[x.length - 1] == '!') {
    x = x.substring(0, x.length - 1);
  }
  if (x[0] == '#') {
    var qualifier_splits = x.split('/');
    return isQualifier(qualifier_splits[0]) &&
        qualifier_splits.sublist(1).every((element) => isSubQualifier(element));
  } else if (x[0] == '\$') {
    return isRestricted(x);
  } else {
    var asset_splits = x.split('/');
    if (asset_splits.length > 1) {
      var last_asset = asset_splits[asset_splits.length - 1];
      if (last_asset.contains('#')) {
        var last_split = last_asset.split('#');
        if (asset_splits.length > 1) {
          return isMainAsset(asset_splits[0]) &&
              asset_splits
                  .sublist(1, asset_splits.length - 1)
                  .every((element) => isSubAsset(element)) &&
              isSubAsset(last_split[0]) &&
              isNFT(last_split[1]);
        } else {
          return isMainAsset(last_split[0]) && isNFT(last_split[1]);
        }
      } else if (last_asset.contains('~')) {
        var last_split = last_asset.split('~');
        if (asset_splits.length > 1) {
          return isMainAsset(asset_splits[0]) &&
              asset_splits
                  .sublist(1, asset_splits.length - 1)
                  .every((element) => isSubAsset(element)) &&
              isSubAsset(last_split[0]) &&
              isChannel(last_split[1]);
        } else {
          return isMainAsset(last_split[0]) && isChannel(last_split[1]);
        }
      } else {
        return isMainAsset(asset_splits[0]) &&
            asset_splits.sublist(1).every((element) => isSubAsset(element));
      }
    }
    if (x.contains('#')) {
      var last_split = x.split('#');
      return isMainAsset(last_split[0]) && isNFT(last_split[1]);
    } else if (x.contains('~')) {
      var last_split = x.split('~');
      return isMainAsset(last_split[0]) && isChannel(last_split[1]);
    } else {
      return isMainAsset(x);
    }
  }
}

// The following are only for their specific part in the asset
bool isMainAsset(String x) =>
    x.contains(ROOT_NAME_CHARACTERS) &&
    !x.contains(DOUBLE_PUNCTUATION) &&
    !x.contains(LEADING_PUNCTUATION) &&
    !x.contains(TRAILING_PUNCTUATION) &&
    !x.contains(RAVEN_NAMES);
bool isSubAsset(String x) =>
    x.contains(SUB_NAME_CHARACTERS) &&
    !x.contains(DOUBLE_PUNCTUATION) &&
    !x.contains(LEADING_PUNCTUATION) &&
    !x.contains(TRAILING_PUNCTUATION);
bool isNFT(String x) => x.contains(UNIQUE_TAG_CHARACTERS);
bool isChannel(String x) =>
    x.length <= MAX_CHANNEL_NAME_LENGTH &&
    x.contains(MSG_CHANNEL_TAG_CHARACTERS) &&
    !x.contains(DOUBLE_PUNCTUATION) &&
    !x.contains(LEADING_PUNCTUATION) &&
    !x.contains(TRAILING_PUNCTUATION);
bool isQualifier(String x) =>
    x.contains(QUALIFIER_NAME_CHARACTERS) &&
    !x.contains(DOUBLE_PUNCTUATION) &&
    !x.contains(QUALIFIER_LEADING_PUNCTUATION) &&
    !x.contains(TRAILING_PUNCTUATION) &&
    !x.contains(RAVEN_NAMES);
bool isSubQualifier(String x) =>
    x.contains(SUB_QUALIFIER_NAME_CHARACTERS) &&
    !x.contains(DOUBLE_PUNCTUATION) &&
    !x.contains(LEADING_PUNCTUATION) &&
    !x.contains(TRAILING_PUNCTUATION);

bool isQualifierString(String x) =>
    x == 'true' ||
    (x.length <= MAX_VERIFIER_STRING &&
        x
            .replaceAll(RegExp(r'\s+'), '')
            .replaceAll(RegExp(r'[\(\)]'), '')
            .contains(QUALIFING_STRING_LOGIC_NO_PARENTHESIS) &&
        !x.replaceAll(RegExp(r'\s+'), '').contains(EMPTY_PARENTHESIS) &&
        x.replaceAll(RegExp(r'\s+'), '').split('').fold(0,
                (num previousValue, element) {
              if (element == '(') {
                return previousValue + 1;
              } else if (element == ')') {
                if (previousValue == 0) {
                  // End parenthsis with no beginning
                  return 50000;
                }
                return previousValue - 1;
              }
              return previousValue;
            }) ==
            0 &&
        !x.contains(DOUBLE_PUNCTUATION) &&
        !x.contains(QUALIFIER_LEADING_PUNCTUATION) &&
        !x.contains(TRAILING_PUNCTUATION) &&
        !x.contains(RAVEN_NAMES) &&
        x.replaceAll(RegExp(r'[\(\)|&!]'), ' ').split(' ').every(
            (element) => element.isEmpty ? true : isQualifier('#' + element)));
bool isRestricted(String x) =>
    x.contains(RESTRICTED_NAME_CHARACTERS) &&
    !x.contains(DOUBLE_PUNCTUATION) &&
    !x.contains(LEADING_PUNCTUATION) &&
    !x.contains(TRAILING_PUNCTUATION) &&
    !x.contains(RAVEN_NAMES);
// bool isVote(String x) => x.contains(RegExp(r'^$')); // Unused
bool isMemo(String x) => x.contains(RegExp(r'^.{1,80}$')); // byte len <80
bool isAssetMemo(String x) => isIpfs(x) || isTxIdFlow(x);
bool isRVNAmount(num x) => x <= 21000000000 && x > 0;
