import '../../electrum_client.dart';

class ScriptHashBalance {
  int confirmed;
  int unconfirmed;
  ScriptHashBalance(this.confirmed, this.unconfirmed);

  int get value {
    return confirmed + unconfirmed;
  }

  @override
  String toString() {
    return 'ScriptHashBalance(confirmed: $confirmed, unconfirmed: $unconfirmed)';
  }
}

extension GetBalanceMethod on ElectrumClient {
  Future<ScriptHashBalance> getBalance({scriptHash}) async {
    var proc = 'blockchain.scripthash.get_balance';
    dynamic balance = await request(proc, [scriptHash]);
    return ScriptHashBalance(balance['confirmed'], balance['unconfirmed']);
  }
}
