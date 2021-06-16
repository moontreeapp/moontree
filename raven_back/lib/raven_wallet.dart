import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:raven/wallet_exposure.dart';
import 'raven_network_params.dart';

List<int> reverse(List<int> hex) {
  var buffer = Uint8List(hex.length);

  for (var i = 0, j = hex.length - 1; i <= j; ++i, --j) {
    buffer[i] = hex[j];
    buffer[j] = hex[i];
  }

  return buffer;
}

class RavenWallet {
  final RavenNetworkParams _params;
  final HDWallet _wallet;

  RavenWallet(params, wallet)
      : _params = params,
        _wallet = wallet;

  HDWallet getHDWallet(int index, {exposure = WalletExposure.External}) {
    return _wallet
        .derivePath(_params.derivationPath(index, exposure: exposure));
  }

  Uint8List toOutputScript(int index, {exposure = WalletExposure.External}) {
    var hdwallet = getHDWallet(index, exposure: exposure);
    print('address: ${hdwallet.address}');
    return Address.addressToOutputScript(hdwallet.address, _params.network);
  }

  String scriptHashFromAddress(int index,
      {exposure = WalletExposure.External}) {
    var script = toOutputScript(index, exposure: exposure);
    Digest digest = sha256.convert(script);
    var hash = reverse(digest.bytes);
    return hex.encode(hash);
  }
}
