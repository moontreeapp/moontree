import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:raven/network_params.dart';
import 'network_params.dart';

export 'raven_networks.dart';

class Account {
  final NetworkParams params;
  final HDWallet _wallet;
  final Uint8List seed;
  //final gapLimit _gap_limit;

  Account(this.params, {required this.seed})
      : _wallet = HDWallet.fromSeed(seed, network: params.network);
  //_gap_limit = 20;

  _HDNode node(int index, {exposure = NodeExposure.External}) {
    var wallet =
        _wallet.derivePath(params.derivationPath(index, exposure: exposure));
    return _HDNode(params, wallet, index, exposure);
  }

  //Map getTransactions(int index, {exposure = NodeExposure.External}) {
  //  String scriptHash = scriptHashFromAddress(index, exposure: exposure);
  //  var balance = await client.getBalance(scriptHash);
  //  this wallet doesn't have the ability to it's own balance because it doesn't have a client... could use a client though...
  //}

  /* Transactions functions - 'inspired' by BlueWallet - work in progress */

  /*
    /**
     * Derives from hierarchy, returns next free CHANGE address
     * (the one that has no transactions). Looks for several,
     * gives up if none found, and returns the used one
     *
     * @return {Promise.<string>}
     */
    async getChangeAddressAsync() {
      // looking for free internal address
      let freeAddress = '';
      let c;
      for (c = 0; c < this.gap_limit + 1; c++) {
        if (this.next_free_change_address_index + c < 0) continue;
        const address = this._getInternalAddressByIndex(this.next_free_change_address_index + c);
        this.internal_addresses_cache[this.next_free_change_address_index + c] = address; // updating cache just for any case
        let txs = [];
        try {
          await BlueElectrum.getTransactionsByAddress({address: address, network: this.getNetwork()});
        } catch (Err) {
          console.warn('BlueElectrum.getTransactionsByAddress()', Err.message);
        }
        if (txs.length === 0) {
          // found free address
          freeAddress = address;
          this.next_free_change_address_index += c; // now points to _this one_
          break;
        }
      }

      if (!freeAddress) {
        // could not find in cycle above, give up
        freeAddress = this._getInternalAddressByIndex(this.next_free_change_address_index + c); // we didnt check this one, maybe its free
        this.next_free_change_address_index += c; // now points to this one
      }
      this._address = freeAddress;
      return freeAddress;
    }
  */
  //Uint8List getChangeAddress() {
  //  var exposure = NodeExposure.Internal;
  //  String freeAddress = '';
  //  for (var c = 0; c < gap_limit + 1; c++) {
  //    var hdwallet = getHDWallet(index, exposure: exposure);
  //    // if (this.next_free_change_address_index + c < 0) continue;  //?
  //    const address = this._getInternalAddressByIndex(this.next_free_change_address_index + c);
  //    this.internal_addresses_cache[this.next_free_change_address_index + c] = address; // updating cache just for any case
  //    let txs = [];
  //    try {
  //      await BlueElectrum.getTransactionsByAddress({address: address, network: this.getNetwork()});
  //    } catch (Err) {
  //      console.warn('BlueElectrum.getTransactionsByAddress()', Err.message);
  //    }
  //    if (txs.length === 0) {
  //      // found free address
  //      freeAddress = address;
  //      this.next_free_change_address_index += c; // now points to _this one_
  //      break;
  //    }
  //  }
  //  var hdwallet = getHDWallet(index, exposure: exposure);
  //  print('address: ${hdwallet.address}');
  //  return Address.addressToOutputScript(hdwallet.address, _params.network);
  //}

}

List<int> reverse(List<int> hex) {
  var buffer = Uint8List(hex.length);

  for (var i = 0, j = hex.length - 1; i <= j; ++i, --j) {
    buffer[i] = hex[j];
    buffer[j] = hex[i];
  }

  return buffer;
}

class _HDNode {
  NetworkParams params;
  HDWallet wallet;
  int index;
  NodeExposure exposure;

  _HDNode(this.params, this.wallet, this.index, this.exposure);

  Uint8List get outputScript {
    return Address.addressToOutputScript(wallet.address, params.network);
  }

  String get scriptHash {
    Digest digest = sha256.convert(outputScript);
    var hash = reverse(digest.bytes);
    return hex.encode(hash);
  }
}

enum NodeExposure { Internal, External }

String exposureToDerivationPathPart(NodeExposure exposure) {
  switch (exposure) {
    case NodeExposure.External:
      return '0';
    case NodeExposure.Internal:
      return '1';
  }
}
