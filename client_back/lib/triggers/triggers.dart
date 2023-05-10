//import 'asset.dart';
//import 'subscription.dart';
//import 'block.dart';
//import 'client.dart';
import 'rate.dart';
//import 'reissue.dart';
//import 'send.dart';
//import 'unspent.dart';
//import 'setting.dart';
//import 'create.dart';
//import 'address.dart';
//import 'single.dart';
//import 'leader.dart';
import 'app.dart';

class triggers {
  /// needed
  static AppWaiter app = AppWaiter();

  /// not needed
  //static AddressWaiter address = AddressWaiter();
  //static AssetWaiter asset = AssetWaiter();
  //static RavenClientWaiter client = RavenClientWaiter();
  //static SettingWaiter setting = SettingWaiter();
  //static SendWaiter send = SendWaiter();
  //static CreateWaiter create = CreateWaiter();
  //static ReissueWaiter reissue = ReissueWaiter();
  //static UnspentWaiter unspent = UnspentWaiter();
  //static BlockWaiter block = BlockWaiter();

  /// unknown
  static RateWaiter rate = RateWaiter();
  //static SubscriptionWaiter subscription = SubscriptionWaiter();
  //static SingleWaiter single = SingleWaiter();
  //static LeaderWaiter leader = LeaderWaiter();
}
