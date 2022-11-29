import 'package:collection/collection.dart';
import 'package:proclaim/proclaim.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

part 'address.keys.dart';

class AddressProclaim extends Proclaim<_IdKey, Address> {
  late IndexMultiple<_AddressKey, Address> byAddress;
  late IndexMultiple<_WalletKey, Address> byWallet;
  late IndexMultiple<_WalletExposureKey, Address> byWalletExposure;
  late IndexMultiple<_WalletExposureHDKey, Address> byWalletExposureIndex;
  late IndexMultiple<_IdKey, Address> byScripthash;

  AddressProclaim() : super(_IdKey()) {
    byAddress = addIndexMultiple('address', _AddressKey());
    byWallet = addIndexMultiple('wallet', _WalletKey());
    byWalletExposure =
        addIndexMultiple('wallet-exposure', _WalletExposureKey());
    byWalletExposureIndex =
        addIndexMultiple('wallet-exposure-hdindex', _WalletExposureHDKey());
    byScripthash = addIndexMultiple('scripthash', _IdKey());
  }

  void removeAddresses(Wallet wallet) {
    wallet.addresses.forEach((Address address) => primaryIndex.remove(address));
  }
}
