// https://github.com/RavenProject/Ravencoin/blob/master/src/assets/assets.cpp
//// min lengths are expressed by quantifiers
//const ROOT_NAME_CHARACTERS = r"^[A-Z0-9._]{3,}$";
//const SUB_NAME_CHARACTERS = r"^[A-Z0-9._]+$";
//const UNIQUE_TAG_CHARACTERS = r"^[-A-Za-z0-9@$%&*()[\\]{}_.?:]+$";
//const MSG_CHANNEL_TAG_CHARACTERS = r"^[A-Za-z0-9_]+$";
//const VOTE_TAG_CHARACTERS = r"^[A-Z0-9._]+$";
//
//// Restricted assets
//const QUALIFIER_NAME_CHARACTERS = r"#[A-Z0-9._]{3,}$";
//const SUB_QUALIFIER_NAME_CHARACTERS = r"#[A-Z0-9._]+$";
//const RESTRICTED_NAME_CHARACTERS = r"\\$[A-Z0-9._]{3,}$";
//
//// punctuation
//const DOUBLE_PUNCTUATION = r"^.*[._]{2,}.*$";
//const LEADING_PUNCTUATION = r"^[._].*$";
//const TRAILING_PUNCTUATION = r"^.*[._]$";
//const QUALIFIER_LEADING_PUNCTUATION = r"^[#\\$][._].*$";

const MINIMUM_ASSET_LENGTH = 3;
const MAXIMUM_ASSET_LENGTH = 32;

bool isAssetNameGood(String assetName) =>
    goodLength(assetName) && goodType(assetName);

bool goodLength(String assetName) =>
    assetName.length >= MINIMUM_ASSET_LENGTH &&
    assetName.length <= MAXIMUM_ASSET_LENGTH;

bool goodType(String assetName) {
  // #qualifier/#../#subqualifier
  if (assetName.startsWith('#') && assetName.substring(1).contains('#')) {
    return [
      for (var x in assetName.split('/'))
        assetCondition(x, regex: RegExp(r'^[#]{1}[A-Z0-9]{1}[A-Z0-9_.]{2,28}$'))
    ].every((bool item) => item);
  }
  // #qualifier
  if (assetName.startsWith('#')) {
    return assetCondition(assetName,
        regex: RegExp(r'^[#]{1}[A-Z0-9]{1}[A-Z0-9_.]{2,30}$'));
  }
  // $restrictedadmin! ??
  if (assetName.startsWith(r'$') && assetName.endsWith('!')) {
    return assetCondition(assetName,
        regex: RegExp(r'^[$]{1}[A-Z0-9]{1}[A-Z0-9_.]{2,29}[!]{1}$'));
  }
  // $restricted
  if (assetName.startsWith(r'$')) {
    return assetCondition(assetName,
        regex: RegExp(r'^[$]{1}[A-Z0-9]{1}[A-Z0-9_.]{2,30}$'));
  }
  // asset/../sub#nft
  if (assetName.contains('/') && assetName.contains('#')) {
    return [
          for (var x in assetName.split('#').first.split('/')) assetCondition(x)
        ].every((bool item) => item) &&
        assetCondition(assetName.split('#').last,
            regex: RegExp(r'^[A-Z0-9]{1,28}[a-zA-Z0-9@$%&*()\{}_.?:]{2,28}$'));
  }
  // asset#nft
  if (assetName.contains('#')) {
    return assetName.split('#').length == 2 &&
        assetCondition(assetName.split('#').first) &&
        assetCondition(assetName.split('#').last,
            regex: RegExp(r'^[A-Z0-9]{1,28}[a-zA-Z0-9@$%&*()\{}_.?:]{0,28}$'));
  }
  // asset/../sub~msg
  if (assetName.contains('/') && assetName.contains('~')) {
    return assetName.split('~').length == 2 &&
        [for (var x in assetName.split('~').first.split('/')) assetCondition(x)]
            .every((bool item) => item) &&
        assetCondition(assetName.split('~').last,
            regex: RegExp(r'^[A-Z]{1}[A-Z0-9_]{2,28}$'));
  }
  // asset~msg
  if (assetName.contains('~')) {
    return assetName.split('~').length == 2 &&
        assetCondition(
          assetName.split('~').first,
        ) &&
        assetCondition(assetName.split('~').last,
            regex: RegExp(r'^[A-Z]{1}[A-Z0-9_]{2,28}$'));
  }
  // asset/../subadmin!
  if (assetName.contains('/') && assetName.endsWith('!')) {
    return [
          for (var x in assetName
              .split('/')
              .sublist(0, assetName.split('/').length - 1))
            assetCondition(x)
        ].every((bool item) => item) &&
        assetCondition(assetName.split('/').last,
            regex: RegExp(r'^[A-Z0-9]{1}[a-zA-Z0-9_.]{2,29}[!]{0,1}$'));
  }
  // asset/sub
  if (assetName.contains('/')) {
    return [for (var x in assetName.split('/')) assetCondition(x)]
        .every((bool item) => item);
  }
  // admin!
  if (assetName.endsWith('!')) {
    return assetCondition(assetName.split('/').last,
        regex: RegExp(r'^[A-Z0-9]{1}[A-Z0-9_.]{2,30}[!]{0,1}$'));
  }
  // what about votes? ^??
  // asset
  return assetCondition(assetName);
}

bool assetCondition(String asset, {RegExp? regex}) =>
    !asset.contains('..') &&
    !asset.contains('._') &&
    !asset.contains('__') &&
    !asset.contains('_.') &&
    !asset.endsWith('_') &&
    !asset.endsWith('.') &&
    !['RVN', 'RAVEN', 'RAVENCOIN'].contains(asset) &&
    asset.contains(regex ?? RegExp(r'^[A-Z0-9]{1}[A-Z0-9_.]{2,30}$'));
