// ignore_for_file: avoid_classes_with_only_static_members

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
import 'package:ravencoin_front/pages/security/backup/keypair.dart';
import 'package:ravencoin_front/pages/security/backup/intro.dart';
import 'package:ravencoin_front/pages/security/backup/show.dart';
import 'package:ravencoin_front/pages/security/backup/verify.dart';
import 'package:ravencoin_front/pages/security/create_choice.dart';
import 'package:ravencoin_front/pages/security/create_native.dart';
import 'package:ravencoin_front/pages/security/create_password.dart';
import 'package:ravencoin_front/pages/security/login_password.dart';
import 'package:ravencoin_front/pages/security/login_native.dart';
import 'package:ravencoin_front/pages/security/resume.dart';
import 'package:ravencoin_front/pages/security/change_password.dart';
import 'package:ravencoin_front/pages/security/change_method.dart';
import 'package:ravencoin_front/pages/settings/about.dart';
import 'package:ravencoin_front/pages/settings/advanced.dart';
import 'package:ravencoin_front/pages/settings/export.dart';
import 'package:ravencoin_front/pages/settings/feedback.dart';
import 'package:ravencoin_front/pages/settings/import.dart';
import 'package:ravencoin_front/pages/settings/language.dart';
import 'package:ravencoin_front/pages/settings/network.dart';
import 'package:ravencoin_front/pages/settings/mining.dart';
import 'package:ravencoin_front/pages/settings/database.dart';
import 'package:ravencoin_front/pages/settings/developer.dart';
import 'package:ravencoin_front/pages/settings/userlevel.dart';
import 'package:ravencoin_front/pages/settings/preferences.dart';
import 'package:ravencoin_front/pages/settings/support.dart';
import 'package:ravencoin_front/pages/settings/sweep.dart';
import 'package:ravencoin_front/pages/settings/technical.dart';
import 'package:ravencoin_front/pages/settings/addresses.dart';
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
        '/splash': (BuildContext context) => const Splash(),
        '/home': (BuildContext context) => const Home(),
        '/manage/asset': (BuildContext context) => const Asset(),
        '/transactions': (BuildContext context) => const Transactions(),
        '/addresses': (BuildContext context) =>
            const WalletView(), // technical view
        '/scan': (BuildContext context) => const ScanQR(),
        // create and reissue would make better sense if it referenced assets,
        // but actually these should all be improved to match
        // /wallet or /manage or /swap anyway...
        '/create/nft': (BuildContext context) => CreateNFTAsset(),
        '/create/main': (BuildContext context) => CreateMainAsset(),
        '/create/sub': (BuildContext context) => CreateMainSubAsset(),
        '/create/qualifier': (BuildContext context) => CreateQualifierAsset(),
        '/create/qualifiersub': (BuildContext context) =>
            CreateQualifierSubAsset(),
        '/create/channel': (BuildContext context) => CreateChannelAsset(),
        '/create/restricted': (BuildContext context) => CreateRestrictedAsset(),
        '/create/checkout': (BuildContext context) => const Checkout(
              transactionType: TransactionType.create,
            ),
        '/reissue/main': (BuildContext context) => ReissueMainAsset(),
        '/reissue/sub': (BuildContext context) => ReissueMainSubAsset(),
        '/reissue/restricted': (BuildContext context) =>
            ReissueRestrictedAsset(),
        '/reissue/checkout': (BuildContext context) => const Checkout(
              transactionType: TransactionType.reissue,
            ),
        '/security/backup/backupintro': (BuildContext context) =>
            const BackupIntro(),
        '/security/backup': (BuildContext context) => const BackupSeed(),
        '/security/backupKeypair': (BuildContext context) =>
            const ShowKeypair(),
        '/security/backupConfirm': (BuildContext context) => const VerifySeed(),
        '/security/password/change': (BuildContext context) =>
            ChangeLoginPassword(),
        '/security/method/change': (BuildContext context) =>
            ChangeLoginMethod(),
        '/security/resume': (BuildContext context) => ChangeResume(),
        '/security/password/login': (BuildContext context) => LoginPassword(),
        '/security/native/login': (BuildContext context) => LoginNative(),
        '/security/create/setup': (BuildContext context) =>
            const CreateChoice(),
        '/security/password/createlogin': (BuildContext context) =>
            const CreatePassword(),
        '/security/native/createlogin': (BuildContext context) =>
            const CreateNative(),
        '/security/security': (BuildContext context) =>
            const VerifyAuthentication(),
        '/transaction/transaction': (BuildContext context) =>
            const TransactionPage(),
        '/transaction/receive': (BuildContext context) => const Receive(),
        '/transaction/send': (BuildContext context) => const Send(),
        '/transaction/checkout': (BuildContext context) => const Checkout(
              transactionType: TransactionType.spend,
            ),
        '/settings/export/export': (BuildContext context) =>
            const Checkout(transactionType: TransactionType.export),
        '/settings/about': (BuildContext context) => About(),
        '/settings/level': (BuildContext context) => const Advanced(),
        '/settings/currency': (BuildContext context) => Language(),
        '/settings/export': (BuildContext context) => const Export(),
        '/settings/feedback': (BuildContext context) => const Feedback(),
        '/settings/import': (BuildContext context) => const Import(),
        //'/settings/network': (context) => ElectrumNetwork(),
        '/settings/network/mining': (BuildContext context) =>
            const MiningChoice(),
        //'/settings/network/blockchain': (context) => BlockchainChoices(),
        '/settings/network/blockchain': (BuildContext context) =>
            const ElectrumNetworkPage(),
        '/settings/preferences': (BuildContext context) => Preferences(),
        '/settings/support': (BuildContext context) => Support(),
        '/settings/technical': (BuildContext context) => const TechnicalView(),
        '/settings/database': (BuildContext context) => const DatabaseOptions(),
        '/settings/developer': (BuildContext context) =>
            const DeveloperOptions(),
        '/settings/advanced': (BuildContext context) =>
            const AdvancedDeveloperOptions(),
        '/settings/sweep': (BuildContext context) => SweepPage(),
      };
}
