import 'package:collection/collection.dart';
import 'package:proclaim/proclaim.dart';
import 'package:client_back/client_back.dart';

part 'address.keys.dart';

class AddressProclaim extends Proclaim<_IdKey, Address> {
  late IndexMultiple<_H160Key, Address> byH160;
  late IndexMultiple<_ScripthashKey, Address> byScripthash;
  late IndexMultiple<_WalletKey, Address> byWallet;
  late IndexMultiple<_WalletExposureKey, Address> byWalletExposure;

  AddressProclaim() : super(_IdKey()) {
    byH160 = addIndexMultiple('byH160', _H160Key());
    byScripthash = addIndexMultiple('byScripthash', _ScripthashKey());
    byWallet = addIndexMultiple('byWallet', _WalletKey());
    byWalletExposure =
        addIndexMultiple('byWalletExposure', _WalletExposureKey());
  }

  /// this is slower because it can't be precomputed
  Address? byAddress(String address, Chain chain, Net net) =>
      records.where((e) => e.address(chain, net) == address).firstOrNull;
}
