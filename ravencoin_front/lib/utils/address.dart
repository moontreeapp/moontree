import 'package:moontree_utils/moontree_utils.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

bool rvnCondition(String address, {Net? net}) =>
    address.contains(RegExp(ravenBase58Regex(net == Net.main)));

bool assetCondition(String asset) =>
    !asset.contains('..') &&
    !asset.contains('._') &&
    !asset.contains('__') &&
    !asset.contains('_.') &&
    !asset.endsWith('_') &&
    !asset.endsWith('.') &&
    !<String>['RVN', 'RAVEN', 'RAVENCOIN'].contains(asset) &&
    asset.contains(RegExp(assetBaseRegex));

/// unused but meant to verify a whole asset string such as:
/// 'FANFT/RAVENHEAD24#PaintedRVN5'
bool wholeAssetCondition(String asset) =>
    assetCondition(asset.split('/').first) &&
    asset
        .split('/')
        .getRange(1, asset.split('/').length)
        .every((String element) => subAssetCondition(element));

/// unused but meant to verify a sub asset string such as:
/// 'RAVENHEAD24#PaintedRVN5'
/// subassets can have lowercase, we need to verify the logic is sound once
/// this kind of functionality is called for
bool subAssetCondition(String asset) =>
    !asset.contains('..') &&
    !asset.contains('._') &&
    !asset.contains('__') &&
    !asset.contains('_.') &&
    !asset.contains('##') &&
    !asset.contains('#.') &&
    !asset.contains('#_') &&
    !asset.contains('.#') &&
    !asset.contains('_#') &&
    !asset.endsWith('_') &&
    !asset.endsWith('.') &&
    asset.length >= 3 &&
    !<String>['RVN', 'RAVEN', 'RAVENCOIN'].contains(asset) &&
    asset.contains(RegExp(subAssetBaseRegex));

/// not complete. todo
bool unsCondition(String address) =>
    address.toLowerCase().endsWith('.crypto') ||
    address.toLowerCase().endsWith('.zil');

/// returns the name of the type of address it is,
/// if the address is preliminarily recognized as conforming to a
/// known format from which we could potentially derive a valid RVN address
String validateAddressType(String address) => rvnCondition(address)
    ? 'RVN'
    : rvnCondition(address, net: Net.test)
        ? 'RVNt'
        //: unsCondition(address)
        //    ? 'UNS'
        //    : assetCondition(address)
        //        ? 'ASSET'
        : '';

/// returns a valid RVN address from the data provided,
/// or empty string if a valid address cannot be derived.
/// potentially we could derivde a valid address from:
///   a valid address
///   asset name
///   unstoppabledomains domain
/// one other thing to consider - asset names are valid unstoppable domains
/// so if we're going to support multiple of these we have to ask the user
/// which one they want. might be too much. maybe you an turn it on in an
/// advanced setting or something.
Future<String> verifyValidAddress(String address) async {
  address = address.trim();
  if (rvnCondition(address)) {
    // mainnet address such as RVNGuyEE9nBUt6aQbwVAhvEjcw7D3c6p2K
    return address;
    //} else if (unsCondition(address)) {
    // ignore: todo
    //  /// TODO:
    //  /// unstoppable domain address... use API
    //  /// https://docs.unstoppabledomains.com/send-and-receive-crypto-payments/crypto-payments#api-endpoints
    //  /// https://drive.google.com/file/d/107oHjLoOHti111FuLvcSl3HVsLJdJCwD/view
    //  ///
    //  /// emailed them for api key
    //  /// we will be unable to save the api key in the opensource code,
    //  /// so we'll either have to add that in manually during build
    //  /// or stand up a server of our own (which I'm sure we'll do eventually anyway)
    //  /// which will take incoming requests and relay them to UNS servers.
    //  ///
    //  return '';
    //} else if (assetCondition(address)) {
    //  // is it a raven asset name. look up who minted the asset and send to them
    //  return await services.client.getOwner(address.toUpperCase());
  }
  return '';
}
