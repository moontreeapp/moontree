import 'account.dart';
import 'address.dart';
import 'address_subscription.dart';
import 'block.dart';
import 'client.dart';
import 'import.dart';
import 'leader.dart';
import 'password.dart';
import 'rate.dart';
import 'send.dart';
import 'setting.dart';
import 'single.dart';

class waiters {
  static AccountWaiter account = AccountWaiter();
  static AddressWaiter address = AddressWaiter();
  static AddressSubscriptionWaiter addressSubscription =
      AddressSubscriptionWaiter();
  static BlockWaiter block = BlockWaiter();
  static ImportWaiter import = ImportWaiter();
  static PasswordWaiter password = PasswordWaiter();
  static RateWaiter rate = RateWaiter();
  static RavenClientWaiter ravenClient = RavenClientWaiter();
  static SendWaiter send = SendWaiter();
  static SettingWaiter setting = SettingWaiter();
  // Wallets
  static LeaderWaiter leader = LeaderWaiter();
  static SingleWaiter single = SingleWaiter();
}
