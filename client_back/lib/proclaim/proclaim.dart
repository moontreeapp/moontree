// ignore_for_file: avoid_classes_with_only_static_members, camel_case_types

import 'asset/asset.dart';
import 'asset/metadata.dart';
import 'asset/security.dart';
import 'core/address.dart';
import 'core/balance.dart';
import 'core/block.dart';
import 'core/rate.dart';
import 'core/setting.dart';
import 'core/status.dart';
import 'core/wallet.dart';
import 'security/cipher.dart';
import 'security/password.dart';
import 'security/secret.dart';
import 'server/cache.dart';
import 'transaction/note.dart';
import 'transaction/transaction.dart';
import 'transaction/unspent.dart';
import 'transaction/vin.dart';
import 'transaction/vout.dart';

export 'asset/asset.dart';
export 'asset/metadata.dart';
export 'asset/security.dart';
export 'core/address.dart';
export 'core/balance.dart';
export 'core/block.dart';
export 'core/rate.dart';
export 'core/setting.dart';
export 'core/status.dart';
export 'core/wallet.dart';
export 'security/cipher.dart';
export 'security/password.dart';
export 'security/secret.dart';
export 'server/cache.dart';
export 'transaction/note.dart';
export 'transaction/transaction.dart';
export 'transaction/unspent.dart';
export 'transaction/vin.dart';
export 'transaction/vout.dart';

class pros {
  static final AddressProclaim addresses = AddressProclaim();
  static final AssetProclaim assets = AssetProclaim();
  static final BlockProclaim blocks = BlockProclaim();
  static final BalanceProclaim balances = BalanceProclaim();
  static final CacheProclaim cache = CacheProclaim();
  static final CipherProclaim ciphers = CipherProclaim();
  static final SecretProclaim secrets = SecretProclaim();
  static final MetadataProclaim metadatas = MetadataProclaim();
  static final NoteProclaim notes = NoteProclaim();
  static final PasswordProclaim passwords = PasswordProclaim();
  static final ExchangeRateProclaim rates = ExchangeRateProclaim();
  static final SecurityProclaim securities = SecurityProclaim();
  static final SettingProclaim settings = SettingProclaim();
  static final StatusProclaim statuses = StatusProclaim();
  static final TransactionProclaim transactions = TransactionProclaim();
  static final UnspentProclaim unspents = UnspentProclaim();
  static final WalletProclaim wallets = WalletProclaim();
  static final VinProclaim vins = VinProclaim();
  static final VoutProclaim vouts = VoutProclaim();
}
