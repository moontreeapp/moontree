/// we're not following this example exactly, we check the length first, then
/// if that checks out we determin which type of asset it is, and for each
/// type we gave a specific check. If it's a path, we break those peices apart
/// and check each one individually.
///
/// https://github.com/RavenProject/Ravencoin/blob/master/src/assets/assets.cpp
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
const NFT_REGEX = r'^[a-zA-Z0-9]{1,}[a-zA-Z0-9@$%&*()\-{}_.?:]{0,}$';
const MSG_REGEX = r'^[A-Z0-9_]{0,12}$';
const QUALIFIER_REGEX = r'^[#]{1}[A-Z0-9]{1}[A-Z0-9_.]{2,}$';
// RAVEN_NAMES("^RVN$|^RAVEN$|^RAVENCOIN$|^#RVN$|^#RAVEN$|^#RAVENCOIN$");

bool isAssetNameGood(String asset) => goodLength(asset) && goodPattern(asset);

bool goodLength(String asset) =>
    (asset.endsWith('!') || asset.startsWith(r'$') || asset.startsWith(r'#'))
        ? (asset.length >= MINIMUM_ASSET_LENGTH &&
            asset.length <= MAXIMUM_ASSET_LENGTH)
        : (asset.length >= MINIMUM_ASSET_LENGTH &&
            asset.length <= MAXIMUM_ASSET_LENGTH - 1);

bool goodPattern(String asset) {
  // #qualifier/#../#subqualifier
  if (asset.startsWith('#') && asset.substring(1).contains('#')) {
    return [
      for (var x in asset.split('/'))
        validate.main(x, regex: RegExp(QUALIFIER_REGEX))
    ].every((bool item) => item);
  }
  // #qualifier
  if (asset.startsWith('#')) {
    return validate.main(asset, regex: RegExp(QUALIFIER_REGEX));
  }
  // $restricted
  if (asset.startsWith(r'$')) {
    return validate.main(asset,
        regex: RegExp(r'^[$]{1}[A-Z0-9]{1}[A-Z0-9_.]{2,}$'));
  }
  // asset/../sub#nft
  if (asset.contains('/') && asset.contains('#')) {
    if (asset.split('#').length != 2) return false;
    var parts = getParts(asset, '#');
    return validate.main(parts['head']) &&
        validate.subs(parts['subs']) &&
        validate.main(
          parts['tail'],
          regex: RegExp(NFT_REGEX),
        );
  }
  // asset#nft
  if (asset.contains('#')) {
    if (asset.split('#').length != 2) return false;
    var parts = getParts(asset, '#');
    return validate.main(parts['head']) &&
        validate.main(
          parts['tail'],
          regex: RegExp(NFT_REGEX),
        );
  }
  // asset/../sub~msg
  if (asset.contains('/') && asset.contains('~')) {
    if (asset.split('~').length != 2) return false;
    var parts = getParts(asset, '~');
    return validate.main(parts['head']) &&
        validate.subs(parts['subs']) &&
        validate.main(
          parts['tail'],
          regex: RegExp(MSG_REGEX),
        );
  }
  // asset~msg
  if (asset.contains('~')) {
    if (asset.split('~').length != 2) return false;
    var parts = getParts(asset, '~');
    return validate.main(parts['head']) &&
        validate.main(
          parts['tail'],
          regex: RegExp(MSG_REGEX),
        );
  }
  // asset/../subadmin!
  if (asset.contains('/') && asset.endsWith('!')) {
    if (asset.split('!').length != 2) return false;
    var parts = getParts(asset, '!');
    return validate.main(parts['head']) && validate.subs(parts['subs']);
  }
  // asset/sub
  if (asset.contains('/')) {
    var parts = getParts(asset, '***');
    return validate.main(parts['head']) && validate.subs(parts['subs']);
  }
  // admin!
  if (asset.endsWith('!')) {
    return validate.main(asset,
        regex: RegExp(r'^[A-Z0-9]{1}[A-Z0-9_.]{2,}[!]{1}$'));
  }
  // what about votes? ^??
  // asset
  return validate.main(asset);
}

Map<String, dynamic> getParts(String asset, String special) => {
      'head': asset.split(special).first.split('/').first,
      'subs': asset.split(special).first.split('/').sublist(1),
      'tail': asset.split(special).last,
    };

class validate {
  static bool main(String asset, {RegExp? regex}) =>
      punc(asset) &&
      !['RVN', 'RAVEN', 'RAVENCOIN'].contains(asset) &&
      asset.contains(regex ?? RegExp(r'^[A-Z0-9]{1}[A-Z0-9_.]{2,}$'));

  static bool sub(String asset, {RegExp? regex}) =>
      punc(asset) &&
      asset.contains(regex ?? RegExp(r'^[A-Z0-9]{1}[A-Z0-9_.]{0,}$'));

  static bool subs(List subs) =>
      [for (var s in subs) sub(s)].every((bool item) => item);

  static bool punc(String asset) =>
      !asset.contains('..') &&
      !asset.contains('._') &&
      !asset.contains('__') &&
      !asset.contains('_.') &&
      !asset.endsWith('_') &&
      !asset.endsWith('.');
}
