import 'package:flutter/cupertino.dart';
import 'package:raven_front/pages/home/home.dart';
import 'package:raven_front/pages/wallet/transactions.dart';
import 'package:raven_front/pages/manage/assets.dart';
import 'package:raven_front/pages/manage/create/nft.dart';
import 'package:raven_front/pages/manage/create/main.dart';
import 'package:raven_front/pages/manage/create/sub.dart';
import 'package:raven_front/pages/manage/create/qualifier.dart';
import 'package:raven_front/pages/manage/create/qualifiersub.dart';
import 'package:raven_front/pages/manage/create/channel.dart';
import 'package:raven_front/pages/manage/create/restricted.dart';
import 'package:raven_front/pages/manage/reissue/restricted.dart';
import 'package:raven_front/pages/manage/reissue/main.dart';
import 'package:raven_front/pages/manage/reissue/sub.dart';
import 'package:raven_front/pages/misc/loading.dart';
import 'package:raven_front/pages/misc/splash.dart';
import 'package:raven_front/pages/misc/scan.dart';
import 'package:raven_front/pages/settings/backup/show.dart';
import 'package:raven_front/pages/settings/backup/verify.dart';
import 'package:raven_front/pages/settings/security/login.dart';
import 'package:raven_front/pages/settings/security/remove.dart';
import 'package:raven_front/pages/settings/security/resume.dart';
import 'package:raven_front/pages/settings/security/change.dart';
import 'package:raven_front/pages/settings/about.dart';
//import 'package:raven_front/pages/settings/currency.dart';
import 'package:raven_front/pages/settings/export.dart';
import 'package:raven_front/pages/settings/feedback.dart';
import 'package:raven_front/pages/settings/import.dart';
import 'package:raven_front/pages/settings/language.dart';
import 'package:raven_front/pages/settings/network.dart';
import 'package:raven_front/pages/settings/advanced.dart';
import 'package:raven_front/pages/settings/preferences.dart';
import 'package:raven_front/pages/settings/security.dart';
import 'package:raven_front/pages/settings/support.dart';
import 'package:raven_front/pages/settings/technical.dart';
import 'package:raven_front/pages/misc/checkout.dart';
import 'package:raven_front/pages/wallet/receive.dart';
import 'package:raven_front/pages/wallet/send.dart';
import 'package:raven_front/pages/wallet/transaction.dart';
import 'package:raven_front/pages/settings/wallet.dart';
import 'package:raven_front/widgets/front/loader.dart';

class pages {
  // static Splash splash = Splash();
  // static Loading loading = Loading();
  // static ChangePassword changePassword = ChangePassword();
  // static ChangeResume changeResume = ChangeResume();
  // static Login login = Login();
  // static Home home = Home();
  // static Asset asset = Asset();
  // static Transactions transactions = Transactions();
  // static CreateNFTAsset createNFTAsset = CreateNFTAsset();
  // static CreateMainAsset createMainAsset = CreateMainAsset();
  // static CreateMainSubAsset createMainSubAsset = CreateMainSubAsset();
  // static CreateQualifierAsset createQualifierAsset = CreateQualifierAsset();
  // static CreateQualifierSubAsset createQualifierSubAsset =
  //     CreateQualifierSubAsset();
  // static CreateChannelAsset createChannelAsset = CreateChannelAsset();
  // static CreateRestrictedAsset createRestrictedAsset = CreateRestrictedAsset();
  // static Checkout checkout = Checkout();
  // static TransactionPage transaction = TransactionPage();
  // static Receive receive = Receive();
  // static Send send = Send();
  // static About about = About();
  // static Advanced advanced = Advanced();
  // static Export export = Export();
  // static Feedback feedback = Feedback();
  // static Import import = Import();
  // static Language language = Language();
  // static Loader loader = Loader();
  // static ElectrumNetwork electrumNetwork = ElectrumNetwork();
  // static Preferences preferences = Preferences();
  // static RemovePassword removePassword = RemovePassword();
  // static Currency currency = Currency();
  // static ScanQR scan = ScanQR();
  // static Support support = Support();
  // static BackupSeed backupShow = BackupSeed();
  // static VerifySeed backupVerify = VerifySeed();
  // static Security security = Security();
  // static TechnicalView technicalView = TechnicalView();
  // static WalletView walletView = WalletView();

  static Map<String, Widget Function(BuildContext)> routes(
          BuildContext context) =>
      {
        '/': (context) => Splash(),
        '/splash': (context) => Splash(),
        '/loading': (context) => Loading(),
        '/home': (context) => Home(),
        '/manage/asset': (context) => Asset(),
        '/transactions': (context) => Transactions(),
        '/wallet': (context) => WalletView(),
        '/loader': (context) => Loader(),
        '/scan': (context) => ScanQR(),
        '/create/nft': (context) => CreateNFTAsset(),
        '/create/main': (context) => CreateMainAsset(),
        '/create/sub': (context) => CreateMainSubAsset(),
        '/create/qualifier': (context) => CreateQualifierAsset(),
        '/create/qualifiersub': (context) => CreateQualifierSubAsset(),
        '/create/channel': (context) => CreateChannelAsset(),
        '/create/restricted': (context) => CreateRestrictedAsset(),
        '/reissue/main': (context) => ReissueMainAsset(),
        '/reissue/sub': (context) => ReissueMainSubAsset(),
        '/reissue/restricted': (context) => ReissueRestrictedAsset(),
        '/security/backup': (context) => BackupSeed(),
        '/security/backupConfirm': (context) => VerifySeed(),
        '/security/change': (context) => ChangePassword(),
        '/security/resume': (context) => ChangeResume(),
        '/security/remove': (context) => RemovePassword(),
        '/security/login': (context) => Login(),
        '/transaction/transaction': (context) => TransactionPage(),
        '/transaction/receive': (context) => Receive(),
        '/transaction/send': (context) => Send(),
        '/transaction/checkout': (context) => Checkout(),
        '/settings/export/export': (context) => Checkout(),
        '/settings/about': (context) => About(),
        '/settings/level': (context) => Advanced(),
        '/settings/currency': (context) => Language(),
        '/settings/export': (context) => Export(),
        '/settings/feedback': (context) => Feedback(),
        '/settings/import': (context) => Import(),
        '/settings/network': (context) => ElectrumNetwork(),
        '/settings/preferences': (context) => Preferences(),
        '/settings/security': (context) => Security(),
        '/settings/support': (context) => Support(),
        '/settings/technical': (context) => TechnicalView(),
      };
}
