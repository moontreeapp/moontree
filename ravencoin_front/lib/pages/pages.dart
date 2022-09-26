import 'package:flutter/cupertino.dart';
import 'package:ravencoin_front/pages/home/home.dart';
import 'package:ravencoin_front/pages/manage/assets.dart';
import 'package:ravencoin_front/pages/manage/create/nft.dart';
import 'package:ravencoin_front/pages/manage/create/main.dart';
import 'package:ravencoin_front/pages/manage/create/sub.dart';
import 'package:ravencoin_front/pages/manage/create/qualifier.dart';
import 'package:ravencoin_front/pages/manage/create/qualifiersub.dart';
import 'package:ravencoin_front/pages/manage/create/channel.dart';
import 'package:ravencoin_front/pages/manage/create/restricted.dart';
import 'package:ravencoin_front/pages/manage/reissue/restricted.dart';
import 'package:ravencoin_front/pages/manage/reissue/main.dart';
import 'package:ravencoin_front/pages/manage/reissue/sub.dart';
import 'package:ravencoin_front/pages/misc/splash.dart';
import 'package:ravencoin_front/pages/misc/scan.dart';
import 'package:ravencoin_front/pages/misc/checkout.dart';
import 'package:ravencoin_front/pages/security/backup/show.dart';
import 'package:ravencoin_front/pages/security/backup/verify.dart';
import 'package:ravencoin_front/pages/security/create_native.dart';
import 'package:ravencoin_front/pages/security/create_password.dart';
import 'package:ravencoin_front/pages/security/login_password.dart';
import 'package:ravencoin_front/pages/security/login_native.dart';
import 'package:ravencoin_front/pages/security/resume.dart';
import 'package:ravencoin_front/pages/security/change_password.dart';
import 'package:ravencoin_front/pages/security/change_method.dart';
import 'package:ravencoin_front/pages/settings/about.dart';
import 'package:ravencoin_front/pages/settings/export.dart';
import 'package:ravencoin_front/pages/settings/feedback.dart';
import 'package:ravencoin_front/pages/settings/import.dart';
import 'package:ravencoin_front/pages/settings/language.dart';
import 'package:ravencoin_front/pages/settings/network.dart';
import 'package:ravencoin_front/pages/settings/network_options.dart';
import 'package:ravencoin_front/pages/settings/advanced.dart';
import 'package:ravencoin_front/pages/settings/preferences.dart';
import 'package:ravencoin_front/pages/settings/support.dart';
import 'package:ravencoin_front/pages/settings/technical.dart';
//import 'package:ravencoin_front/pages/settings/currency.dart';
//import 'package:ravencoin_front/pages/settings/wallet.dart';
import 'package:ravencoin_front/pages/wallet/receive.dart';
import 'package:ravencoin_front/pages/wallet/send.dart';
import 'package:ravencoin_front/pages/wallet/transaction.dart';
//import 'package:ravencoin_front/pages/wallet/transactions.dart';
import 'package:ravencoin_front/pages/wallet/transactions/widget.dart';
import 'package:ravencoin_front/widgets/front/verify.dart';

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
        '/splash': (context) => Splash(),
        '/home': (context) => Home(),
        '/manage/asset': (context) => Asset(),
        '/transactions': (context) => Transactions(),
        //'/wallet': (context) => WalletView(), // technical view
        '/scan': (context) => ScanQR(),
        // create and reissue would make better sense if it referenced assets,
        // but actually these should all be improved to match
        // /wallet or /manage or /swap anyway...
        '/create/nft': (context) => CreateNFTAsset(),
        '/create/main': (context) => CreateMainAsset(),
        '/create/sub': (context) => CreateMainSubAsset(),
        '/create/qualifier': (context) => CreateQualifierAsset(),
        '/create/qualifiersub': (context) => CreateQualifierSubAsset(),
        '/create/channel': (context) => CreateChannelAsset(),
        '/create/restricted': (context) => CreateRestrictedAsset(),
        '/create/checkout': (context) => Checkout(
              transactionType: TransactionType.Create,
            ),
        '/reissue/main': (context) => ReissueMainAsset(),
        '/reissue/sub': (context) => ReissueMainSubAsset(),
        '/reissue/restricted': (context) => ReissueRestrictedAsset(),
        '/reissue/checkout': (context) => Checkout(
              transactionType: TransactionType.Reissue,
            ),
        '/security/backup': (context) => BackupSeed(),
        '/security/backupConfirm': (context) => VerifySeed(),
        '/security/password/change': (context) => ChangeLoginPassword(),
        '/security/method/change': (context) => ChangeLoginMethod(),
        '/security/resume': (context) => ChangeResume(),
        '/security/password/login': (context) => LoginPassword(),
        '/security/native/login': (context) => LoginNative(),
        '/security/password/createlogin': (context) => CreatePassword(),
        '/security/native/createlogin': (context) => CreateNative(),
        '/security/verification': (context) => VerifyAuthentication(),
        '/transaction/transaction': (context) => TransactionPage(),
        '/transaction/receive': (context) => Receive(),
        '/transaction/send': (context) => Send(),
        '/transaction/checkout': (context) => Checkout(
              transactionType: TransactionType.Spend,
            ),
        '/settings/export/export': (context) =>
            Checkout(transactionType: TransactionType.Export),
        '/settings/about': (context) => About(),
        '/settings/level': (context) => Advanced(),
        '/settings/currency': (context) => Language(),
        '/settings/export': (context) => Export(),
        '/settings/feedback': (context) => Feedback(),
        '/settings/import': (context) => Import(),
        '/settings/network': (context) => ElectrumNetwork(),
        '/settings/network/options': (context) => NetworkOptionsPage(),
        '/settings/preferences': (context) => Preferences(),
        '/settings/support': (context) => Support(),
        '/settings/technical': (context) => TechnicalView(),
      };
}
