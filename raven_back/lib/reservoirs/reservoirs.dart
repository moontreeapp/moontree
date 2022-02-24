import 'address.dart';
import 'asset.dart';
import 'balance.dart';
import 'block.dart';
import 'cipher.dart';
import 'password.dart';
import 'metadata.dart';
import 'rate.dart';
import 'security.dart';
import 'setting.dart';
import 'transaction.dart';
import 'vin.dart';
import 'vout.dart';
import 'wallet.dart';

export 'address.dart';
export 'asset.dart';
export 'balance.dart';
export 'block.dart';
export 'cipher.dart';
export 'password.dart';
export 'metadata.dart';
export 'rate.dart';
export 'security.dart';
export 'setting.dart';
export 'transaction.dart';
export 'vin.dart';
export 'vout.dart';
export 'wallet.dart';

class res {
  static final AddressReservoir addresses = AddressReservoir();
  static final AssetReservoir assets = AssetReservoir();
  static final BlockReservoir blocks = BlockReservoir();
  static final BalanceReservoir balances = BalanceReservoir();
  static final CipherReservoir ciphers = CipherReservoir();
  static final MetadataReservoir metadatas = MetadataReservoir();
  static final PasswordReservoir passwords = PasswordReservoir();
  static final ExchangeRateReservoir rates = ExchangeRateReservoir();
  static final SecurityReservoir securities = SecurityReservoir();
  static final SettingReservoir settings = SettingReservoir();
  static final TransactionReservoir transactions = TransactionReservoir();
  static final WalletReservoir wallets = WalletReservoir();
  static final VinReservoir vins = VinReservoir();
  static final VoutReservoir vouts = VoutReservoir();
}
