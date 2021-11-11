// dart test test/integration/download_asset.dart

import 'package:raven/raven.dart';
import 'package:raven/records/security.dart';
import 'package:raven/utils/parse.dart';
import 'package:raven/services/services.dart';
import 'package:test/test.dart';

import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:raven/services/transaction_maker.dart' as tx;
import 'package:tuple/tuple.dart';

const connectionTimeout = Duration(seconds: 5);
const aliveTimerDuration = Duration(seconds: 2);

void main() {
  test('getHistory', () async {
    //var client = await services.client.createClient();
    var client = RavenElectrumClient(await connect('testnet.rvn.rocks'));
    await client.serverVersion(protocolVersion: '1.9');
    var scripthash =
        'f1f2e3ec85e3d56d4273e3f114cc7c53e24fdd3b93d966c8b29f4247dc542c0c';
    var history = await client.getHistory(scripthash);
    /*
    print(history);
    [
      ScripthashHistory(txHash: 9bc5463610b074a5aa4ea6045c983fbdd787548edccae732e000524b96833713, height: 967002, memo: null), 
      ScripthashHistory(txHash: 4e769a6d770b4e441ade1d5600926ad14f58fdb6ae4128ed03c811241ec72240, height: 969691, memo: null)]
    */
    var tx = await client.getTransaction(
        '4e769a6d770b4e441ade1d5600926ad14f58fdb6ae4128ed03c811241ec72240');
    /*
    print(tx);
    Transaction(
      txid: 4e769a6d770b4e441ade1d5600926ad14f58fdb6ae4128ed03c811241ec72240,
      hash: 4e769a6d770b4e441ade1d5600926ad14f58fdb6ae4128ed03c811241ec72240,
      blockhash: 00000001be966eb7af35eb70c462c69d18f807f769b32ee931836a9e19493a4e,
      blocktime: 1636654655,
      confirmations: 77,
      height: 969691,
      hex: 0200000001133783964b5200e032e7cadc8e5487d7bd3f985c04a64eaaa574b0103646c59b010000006a47304402206caf44e4b10d95d7466f0ebf04b2281496fe9ef108f3f2979188cb81979645be02207d40701d97551f16e14103e8ca4477229dff11ab0ef60fad98611f5146084b0701210237a18afc7b976e0bc3f23625525cdbead53f80b4246e4da95b2e554212c44a61feffffff04a4b7d1494d0400001976a914cfbaa66323335823d5d24481a774d629c57e9fe488ac00743ba40b0000001976a914dda3d21797ff26cb8ae9a769bdc68cf4567f5bba88ac00000000000000002a76a9143a2ecf8e6ba3fc06bea72e594beb48a871916e3688acc00e72766e6f094d4f4f4e54524545217500000000000000005676a9143a2ecf8e6ba3fc06bea72e594beb48a871916e3688acc03a72766e71084d4f4f4e5452454500407a10f35a000000010112208443bcbb6a0118aebfcfe91c125d6e58a87693b73d08f77d77f6e78fa229563c75dacb0e00,
      locktime: 969690,
      size: 371,
      vsize: 371,
      time: 1636654655,
      txid: 4e769a6d770b4e441ade1d5600926ad14f58fdb6ae4128ed03c811241ec72240,
      version: 2,
      vin: [
        TxVin(
          null,
          4294967294,
          9bc5463610b074a5aa4ea6045c983fbdd787548edccae732e000524b96833713,
          1,
          TxScriptSig(
            304402206caf44e4b10d95d7466f0ebf04b2281496fe9ef108f3f2979188cb81979645be02207d40701d97551f16e14103e8ca4477229dff11ab0ef60fad98611f5146084b07[ALL] 0237a18afc7b976e0bc3f23625525cdbead53f80b4246e4da95b2e554212c44a61,
            47304402206caf44e4b10d95d7466f0ebf04b2281496fe9ef108f3f2979188cb81979645be02207d40701d97551f16e14103e8ca4477229dff11ab0ef60fad98611f5146084b0701210237a18afc7b976e0bc3f23625525cdbead53f80b4246e4da95b2e554212c44a61))],
      vout: [
        TxVout(
          47299.974737,
          0,
          4729997473700,
          TxScriptPubKey(
            asm: OP_DUP OP_HASH160 cfbaa66323335823d5d24481a774d629c57e9fe4 OP_EQUALVERIFY OP_CHECKSIG,
            hex: 76a914cfbaa66323335823d5d24481a774d629c57e9fe488ac,
            type: pubkeyhash,
            reqSigs: 1,
            addresses: [mzTKmRpncyWx5NxmNzvmAKJbMXbNSJgrEj],
            asset: null,
            amount: null,
            units: null,
            reissuable: null,
            ipfsHash: null)),
        TxVout(
          500.0,
          1,
          50000000000,
          TxScriptPubKey(
            asm: OP_DUP OP_HASH160 dda3d21797ff26cb8ae9a769bdc68cf4567f5bba OP_EQUALVERIFY OP_CHECKSIG,
            hex: 76a914dda3d21797ff26cb8ae9a769bdc68cf4567f5bba88ac,
            type: pubkeyhash,
            reqSigs: 1,
            addresses: [n1issueAssetXXXXXXXXXXXXXXXXWdnemQ],
            asset: null,
            amount: null,
            units: null,
            reissuable: null,
            ipfsHash: null)),
        TxVout(
          0.0,
          2,
          0,
          TxScriptPubKey(
            asm: OP_DUP OP_HASH160 3a2ecf8e6ba3fc06bea72e594beb48a871916e36 OP_EQUALVERIFY OP_CHECKSIG OP_RVN_ASSET 0e72766e6f094d4f4f4e545245452175,
            hex: 76a9143a2ecf8e6ba3fc06bea72e594beb48a871916e3688acc00e72766e6f094d4f4f4e545245452175,
            type: new_asset,
            reqSigs: 1,
            addresses: [mkpbZecTxmzU78xqeaKAPeeDSfJw2sSAWt],
            asset: MOONTREE!,
            amount: 1,
            units: 0,
            reissuable: 0,
            ipfsHash: null)),
        TxVout(
          0.0,
          3,
          0,
          TxScriptPubKey(
            asm: OP_DUP OP_HASH160 3a2ecf8e6ba3fc06bea72e594beb48a871916e36 OP_EQUALVERIFY OP_CHECKSIG OP_RVN_ASSET 3a72766e71084d4f4f4e5452454500407a10f35a000000010112208443bcbb6a0118aebfcfe91c125d6e58a87693b73d08f77d77f6e78fa229563c75,
            hex: 76a9143a2ecf8e6ba3fc06bea72e594beb48a871916e3688acc03a72766e71084d4f4f4e5452454500407a10f35a000000010112208443bcbb6a0118aebfcfe91c125d6e58a87693b73d08f77d77f6e78fa229563c75,
            type: new_asset,
            reqSigs: 1,
            addresses: [mkpbZecTxmzU78xqeaKAPeeDSfJw2sSAWt],
            asset: MOONTREE,
            amount: 1000000,
            units: 0,
            reissuable: 1,
            ipfsHash: QmXExS4BMc1YrH6iWERyryFcDWkvobxryXSwECLrcd7Y1H))]))
    */
    //for (var vout in tx.vout) {
    //  if (vout.scriptPubKey.type == 'nulldata') continue;
    //  var vs = await services.address.handleAssetData(client, tx, vout);
    //  print(vs);
    //  Vout(
    //    txId: tx.txid,
    //    rvnValue: vs.item1,
    //    position: vout.n,
    //    memo: vout.memo,
    //    type: vout.scriptPubKey.type,
    //    toAddress: vout.scriptPubKey.addresses![0],
    //    assetSecurityId: vs.item2.securityId,
    //    assetValue: vout.scriptPubKey.amount,
    //    // multisig - must detect if multisig...
    //    additionalAddresses: (vout.scriptPubKey.addresses?.length ?? 0) > 1
    //        ? vout.scriptPubKey.addresses!
    //            .sublist(1, vout.scriptPubKey.addresses!.length)
    //        : null,
    //  );
    //}
  });
}
