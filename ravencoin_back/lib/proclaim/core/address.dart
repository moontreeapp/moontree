import 'package:collection/collection.dart';
import 'package:proclaim/proclaim.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

part 'address.keys.dart';

class AddressProclaim extends Proclaim<_IdKey, Address> {
  late IndexMultiple<_AddressKey, Address> byAddress;
  late IndexMultiple<_ScripthashKey, Address> byScripthash;
  late IndexMultiple<_WalletKey, Address> byWallet;
  late IndexMultiple<_WalletChainNetKey, Address> byWalletChainNet;
  late IndexMultiple<_WalletExposureChainNetKey, Address>
      byWalletExposureChainNet;

  AddressProclaim() : super(_IdKey()) {
    byAddress = addIndexMultiple('byAddress', _AddressKey());
    byScripthash = addIndexMultiple('byScripthash', _ScripthashKey());
    byWallet = addIndexMultiple('byWallet', _WalletKey());
    byWalletChainNet =
        addIndexMultiple('byWalletChainNet', _WalletChainNetKey());
    byWalletExposureChainNet = addIndexMultiple(
        'byWalletExposureChainNet', _WalletExposureChainNetKey());
  }
}
