import 'reservoirs/reservoirs.dart';
import 'waiters/waiters.dart';

// RESERVOIRS
class res {
  static final AccountReservoir accounts = AccountReservoir();
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
