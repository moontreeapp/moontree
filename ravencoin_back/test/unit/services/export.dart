import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/wallet/export.dart';
import 'package:test/test.dart';

void main() {
  test('Export', () {
    final service = ExportWalletService();
    final encryptedWIF = EncryptedWIF.fromWIF(
        'cRYoTPs4ahBbp4edtykCg7b33iDhoQfJZfCD5iZS6Jkn3vNw5DQ9', CipherNone());

    final wallet = SingleWallet(
        id: encryptedWIF.walletId,
        encryptedWIF: encryptedWIF.encryptedSecret,
        cipherUpdate: CipherUpdate(CipherType.None),
        name: 'name');

    print('${service.walletsToExportFormat({wallet})}');
  });
}
