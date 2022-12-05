import 'address.dart';
import 'app.dart';
import 'asset.dart';
import 'subscription.dart';
import 'block.dart';
import 'client.dart';
import 'create.dart';
import 'import.dart';
import 'leader.dart';
import 'rate.dart';
import 'reissue.dart';
import 'send.dart';
import 'unspent.dart';
import 'setting.dart';
import 'single.dart';

class waiters {
  static AddressWaiter address = AddressWaiter();
  static AssetWaiter asset = AssetWaiter();
  static AppWaiter app = AppWaiter();
  static SubscriptionWaiter subscription = SubscriptionWaiter();
  static BlockWaiter block = BlockWaiter();
  static CreateWaiter create = CreateWaiter();
  static ImportWaiter import = ImportWaiter();
  static RateWaiter rate = RateWaiter();
  static RavenClientWaiter client = RavenClientWaiter();
  static ReissueWaiter reissue = ReissueWaiter();
  static SendWaiter send = SendWaiter();
  static SettingWaiter setting = SettingWaiter();
  static UnspentWaiter unspent = UnspentWaiter();
  // Wallets
  static LeaderWaiter leader = LeaderWaiter();
  static SingleWaiter single = SingleWaiter();
}
