/// returns a valid RVN address from the data provided,
/// or empty string if a valid address cannot be derived.
/// potentially we could derivde a valid address from:
///   a valid address
///   asset name
///   unstoppabledomains domain
String verifyValidAddress(String address) {
  address = address.trim();

  /// not supporint testnet accounts yet, so mainnet is assumed...
  //if (currentAccount().net == Net.Test) {
  //  //validate testnet addresses
  //} else {//if (currentAccount().net == Net.Main) {
  //  //validate mainnet addresses
  //}
  if (address.startsWith('R') && address.length == 34) {
    // mainnet address such as RVNGuyEE9nBUt6aQbwVAhvEjcw7D3c6p2K
    return address;
  } else if (address.toLowerCase().endsWith('.crypto') ||
      address.toLowerCase().endsWith('.zil')) {
    /// unstoppable domain address... use API
    /// https://docs.unstoppabledomains.com/send-and-receive-crypto-payments/crypto-payments#api-endpoints
    /// https://drive.google.com/file/d/107oHjLoOHti111FuLvcSl3HVsLJdJCwD/view
    ///
    /// emailed them for api key
    /// we will be unable to save the api key in the opensource code,
    /// so we'll either have to add that in manually during build
    /// or stand up a server of our own (which I'm sure we'll do eventually anyway)
    /// which will take incoming requests and relay them to UNS servers.
    ///
    /// TODO
  } else if ( //address == address.toUpperCase() &&
      (address.length >= 3 && address.length <= 30) &&
          (address.contains(RegExp(r'^[a-zA-Z0-9_.]*$')) &&
              !address.contains('..') &&
              !address.contains('.-') &&
              !address.contains('--') &&
              !address.contains('-.') &&
              !address.startsWith('.') &&
              !address.startsWith('_') &&
              !address.endsWith('.') &&
              !address.endsWith('_')) &&
          !['RVN', 'RAVEN', 'RAVENCOIN'].contains(address)) {
    // is it a raven asset name. look up who minted the asset and send to them
    address = address.toUpperCase();

    /// use this endpoint to get tx ID and
    //blockchain.asset.is_qualified(h160, asset)
    //  {
    //    "flag": True,
    //    "height": 1830188,
    //    "txid": "f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6",
    //    "tx_pos": 1
    //  }
    /// then use this endpoint to get the originating address?
    //blockchain.transaction.get(tx_hash, verbose=false)
    //  {
    //  "blockhash": "0000000000000000015a4f37ece911e5e3549f988e855548ce7494a0a08b2ad6",
    //  "blocktime": 1520074861,
    //  "confirmations": 679,
    //  "hash": "36a3692a41a8ac60b73f7f41ee23f5c917413e5b2fad9e44b34865bd0d601a3d",
    //  "hex": "01000000015bb9142c960a838329694d3fe9ba08c2a6421c5158d8f7044cb7c48006c1b484000000006a4730440220229ea5359a63c2b83a713fcc20d8c41b20d48fe639a639d2a8246a137f29d0fc02201de12de9c056912a4e581a62d12fb5f43ee6c08ed0238c32a1ee769213ca8b8b412103bcf9a004f1f7a9a8d8acce7b51c983233d107329ff7c4fb53e44c855dbe1f6a4feffffff02c6b68200000000001976a9141041fb024bd7a1338ef1959026bbba860064fe5f88ac50a8cf00000000001976a91445dac110239a7a3814535c15858b939211f8529888ac61ee0700",
    //  "locktime": 519777,
    //  "size": 225,
    //  "time": 1520074861,
    //  "txid": "36a3692a41a8ac60b73f7f41ee23f5c917413e5b2fad9e44b34865bd0d601a3d",
    //  "version": 1,
    //  "vin": [ {
    //    "scriptSig": {
    //      "asm": "30440220229ea5359a63c2b83a713fcc20d8c41b20d48fe639a639d2a8246a137f29d0fc02201de12de9c056912a4e581a62d12fb5f43ee6c08ed0238c32a1ee769213ca8b8b[ALL|FORKID] 03bcf9a004f1f7a9a8d8acce7b51c983233d107329ff7c4fb53e44c855dbe1f6a4",
    //      "hex": "4730440220229ea5359a63c2b83a713fcc20d8c41b20d48fe639a639d2a8246a137f29d0fc02201de12de9c056912a4e581a62d12fb5f43ee6c08ed0238c32a1ee769213ca8b8b412103bcf9a004f1f7a9a8d8acce7b51c983233d107329ff7c4fb53e44c855dbe1f6a4"
    //    },
    //    "sequence": 4294967294,
    //    "txid": "84b4c10680c4b74c04f7d858511c42a6c208bae93f4d692983830a962c14b95b",
    //    "vout": 0}],
    //  "vout": [ { "n": 0,
    //             "scriptPubKey": { "addresses": [ "12UxrUZ6tyTLoR1rT1N4nuCgS9DDURTJgP"],
    //                               "asm": "OP_DUP OP_HASH160 1041fb024bd7a1338ef1959026bbba860064fe5f OP_EQUALVERIFY OP_CHECKSIG",
    //                               "hex": "76a9141041fb024bd7a1338ef1959026bbba860064fe5f88ac",
    //                               "reqSigs": 1,
    //                               "type": "pubkeyhash"},
    //             "value": 0.0856647},
    //           { "n": 1,
    //             "scriptPubKey": { "addresses": [ "17NMgYPrguizvpJmB1Sz62ZHeeFydBYbZJ"],
    //                               "asm": "OP_DUP OP_HASH160 45dac110239a7a3814535c15858b939211f85298 OP_EQUALVERIFY OP_CHECKSIG",
    //                               "hex": "76a91445dac110239a7a3814535c15858b939211f8529888ac",
    //                               "reqSigs": 1,
    //                               "type": "pubkeyhash"},
    //             "value": 0.1360904}]
    //  }
  }

  return '';
}
