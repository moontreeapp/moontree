import 'package:raven/wallets/pk_wallet.dart';
import '../cipher.dart';
import '../records.dart' as records;
import '../records/net.dart';

class ImportedPrivateKeyWallet extends PrivateKeyWallet {
  ImportedPrivateKeyWallet(privateKey,
      {net = Net.Test, cipher = const NoCipher()})
      : super(privateKey, net: net, cipher: cipher);

  factory ImportedPrivateKeyWallet.fromRecord(
      records.ImportedPrivateKeyWallet record,
      {cipher = const NoCipher()}) {
    return ImportedPrivateKeyWallet(cipher.decrypt(record.encryptedPrivateKey),
        net: record.net, cipher: cipher);
  }

  records.ImportedPrivateKeyWallet toRecord() {
    return records.ImportedPrivateKeyWallet(encryptedPrivateKey, net: net);
  }

  //int get balance => get all my addresses and sum balance (use service)
}
