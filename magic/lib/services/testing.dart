import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/address.dart';
import 'package:magic/presentation/utils/range.dart';

class Testing {
  static void test1() {
    String address = "EJSooxjk5H6ha24WNJp3k9xuFZMoHpQv64";
    try {
      Uint8List h160 = addressToH160(address);
      print('h160: ${hex.encode(h160)}');
      print(
          'backtoAddres: ${Blockchain.evrmoreMain.addressFromH160String(hex.encode(h160))}');
    } catch (e) {
      print('Error: $e');
    }
  }

  static void test() {
    for (final h160 in [
      '6a143a5cb1eaeba34ad0c6a04b76155ec2ea082a',
      '03de6941b114f209dc01bddc384a42baf3041e10',
      'a3f14e2eec76bd0c9ef71eca2af6c6cce880e666',
      'a09f3dff0866d5c22d36833bac9bbca580fa58f9',
      '606af9bc7043dc7658baf4528a99270f71d15105',
      '9b70ab204d67f3658495693923dc0440e9e01fb1',
      '3d6bf8e2a38462b6a5cff7616c16c19ab95c1ae2',
      '52e841a31caf1fc2763a14ea520efc2c9c7e9e09',
      '5ffcea9eb1b75b0d93c619228e1991bbe0a8c972',
      '79fddc986ebbc288dbc68223d2f580de8e63f464',
      'f4ec98fe8322e85276c639ffb8d8baa560a85685',
      '608a97e96c8f7c9599a4cf8e6e4b2fb544f40ce7',
      '9febcceba66801ef414a0bc92a9f2ced17a0208b',
      '254c79f59c6bd91e3c111421aef5f8cbfdc64dca',
      'e7b75fbf24a470fa8d33e8f47e38221dfec4c764',
      'cfd626f235c273118818a96dea97a231c9ff9fb1',
      '2f4f3e7ac52f1aa0d7a6247a1b0b311409b3e53a',
      '9870a4cb8d5febeccd4c531abe61986c7ec78b00',
      '6918aea91f0226a9843aa811af53e161f292c85f',
      'a5761509b1a4f2e657a73330a1c37b6c770e3aa0',
      '0e2a73fd4c0202ab6f057404062e37f97b62bb48',
      'f8db94bbc7ce20fa48ddd9d3c353c4ce11d813c4',
      'e69f60402b8303f820388c3f8175c4ec25a05b3e',
      'ffff8686dac9569d836c053babfac6fa5c9017f7',
      '4677345191a3465683fc559330dd2c8640f77a48',
      '668293bd9bc67995deabec4754cbd7355c6f9516',
      'b098790493de72bd098ab81153283d1da8f07a46',
      'e098d19f54d02d8b88602bc587ee6f7dbc30b262',
      '4d9f61b1276cd0545adc2cecb9a823ea091632ec',
      'df30fa50df86316d73bdf305ebb4866c4cb38955',
      'd57e549076caff664ce48cecfca93455568f59f7',
      'cc1f89971b268968ebe9209846817008fa396785',
      '03123d2346039649dac261d8fd3ce1a0d273ce21',
      'dc349fc89523b7fdafbf1d9322fbb0c9ca892ad9',
      'c6ea64b5b18642e30e525ec4bc7c88be5d093a15',
      '518c0e6fc20f72f2189381b8ba40c5500af72eb4',
      'e0148e47bfb3eadd41b642c6704fd4cf775f8947',
      '5dd5d50b1e9c83814a38217aa01c1067d8f009b7',
      '83187a7c6215c43941dc6926eec95e5f44f9b736',
      '91b28ce606ba1c0d1c0f9e353e189ac6166d0390',
      'b38086bf645298f8dfbbaeb51fff089c4c75fc7b',
      '5cd4716c2f8f8c2e8e5ee44f5998eb3d034b0fc4',
      'c1dbbbdcdeccd8def95b64006eedb5848fc53501',
      'b78c5a0b4a3e8bdd03b8a038ac8752b7d8e280cd',
      'e759278d0bcbea5a4d325cc94cf7452ff50af301',
      'dde22c2b9424026e519db80e9d41948378247fd7',
      '2c4a5bc481a8b5b27a583cf3a89d3f4fb5b4e375',
      'f0c01839a07e1f728ce55f72b74add9903f397c3',
      'ecf6bf4784a6ad7dc00489ed1ce205fd6085234b',
      '812876d56a668d4129e56b346c0ff0f924c4fe1a',
      '3089f83af80bd241a966543a210a8421f08b0328',
      'd4e4ec139ebf8a1b2f36183a2203eba09a6119fe',
      '11dd80eb591fb355b120f4926c7a9ef411e143b4',
      '4f8a84b5767a1099297e6caeb5e9aec909af9ea8',
      '7a98f1e2422b1fa6637dbe2e58b341304d55c944',
      '542f5be928897b6906b135b37b3a6c400adc0487',
      '1d42fb1714728d7438d5d1c1ebbf2fdeafcc9802',
      '4860919b6c5dbc792a5f60e129665172554d55a1',
      '6a42869ab110d1a11c85d503bf71cf1d78af6662',
      'b93fb1d42dc221f18f7ea1344c182a1afe30507a',
      '36a28b04f97a6a24acb75c6a5e3b7e9c29146ac2',
      'e9629bf904dda52e255da4220807769844ea64f6',
      'eba389b789f8d83b73c58314ead2252edcb8cf72',
      '9350da2113cad11bcaeb2596861d6eaa19facb42',
      'f510eba33607d9ec4736ffd106aba9ccaf5c6c8f',
      'b546bb0e8bff515b2f4fcee90317468f68cadb83',
      'ad466e37ba21f9ce74140f40a73cad42a1d4ebf8',
      'ef090f43b329079a8dab7624c19e1cdf1a40fad4',
      '9a840df928b9d38d19e999887fd6a58bddbb945d',
      '9a9cd853be18ed014e355b8ab472914d36a277dc',
      '8248264ad5385e963f1b7d1dd0346ec9fca082e8',
      '606fa03657412e28e9f9a5f73634f31642833979',
      '20f6814a40eea5b3eacf564d40a8a22c8c08fcea',
      '84b8bcf4d468bd88a5f64ecafd4259c89b334b34',
      'fd8af1b20016ca870ea0f31cb46f152f6ab20368',
    ]) {
      print(Blockchain.evrmoreMain.addressFromH160String(h160));
    }
    //for (var i in range(42)) {
    //  print('deriving $i');
    //  cubits.receive
    //      .populateAddresses(Blockchain.evrmoreMain, overrideIndex: i);
    //}
    //print(
    //    'pubkey ${cubits.keys.master.derivationWallets.first.pubkey(Blockchain.evrmoreMain)}');
    //print(
    //    'roots  ${cubits.keys.master.derivationWallets.first.roots(Blockchain.evrmoreMain)}');
    //print('externals');
    //print(cubits.keys.master.derivationWallets.first.seedWallets);
    //print(cubits.keys.master.derivationWallets.first
    //    .seedWallet(Blockchain.evrmoreMain)
    //    .externals
    //    .length);
    //for (var x in cubits.keys.master.derivationWallets.first
    //    .seedWallet(Blockchain.evrmoreMain)
    //    .externals) {
    //  print('address ${x.address}');
    //  print('h160    ${addressToH160(x.address!)}');
    //  print('h160s   ${hex.encode(addressToH160(x.address!))}');
    //}
    //print('internals');
    //for (var x in cubits.keys.master.derivationWallets.first
    //    .seedWallet(Blockchain.evrmoreMain)
    //    .externals) {
    //  print('address ${x.address}');
    //  print('h160    ${addressToH160(x.address!)}');
    //  print('h160s   ${hex.encode(addressToH160(x.address!))}');
    //}
  } //
}//
//
