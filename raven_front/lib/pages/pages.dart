import 'package:flutter/cupertino.dart';
import 'package:raven_front/pages/account/home.dart';
import 'package:raven_front/pages/account/transactions.dart';
import 'package:raven_front/pages/manage/assets.dart';
import 'package:raven_front/pages/create/nft.dart';
import 'package:raven_front/pages/create/main.dart';
import 'package:raven_front/pages/create/sub.dart';
import 'package:raven_front/pages/create/qualifier.dart';
import 'package:raven_front/pages/create/qualifiersub.dart';
import 'package:raven_front/pages/create/channel.dart';
import 'package:raven_front/pages/create/restricted.dart';
import 'package:raven_front/pages/misc/loading.dart';
import 'package:raven_front/pages/misc/splash.dart';
import 'package:raven_front/pages/misc/scan.dart';
import 'package:raven_front/pages/security/backup/show.dart';
import 'package:raven_front/pages/security/backup/verify.dart';
import 'package:raven_front/pages/security/login.dart';
import 'package:raven_front/pages/security/remove.dart';
import 'package:raven_front/pages/security/resume.dart';
import 'package:raven_front/pages/security/change.dart';
import 'package:raven_front/pages/settings/about.dart';
import 'package:raven_front/pages/settings/currency.dart';
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
import 'package:raven_front/pages/transaction/checkout.dart';
import 'package:raven_front/pages/transaction/receive.dart';
import 'package:raven_front/pages/transaction/send.dart';
import 'package:raven_front/pages/transaction/transaction.dart';
import 'package:raven_front/pages/wallet/wallet.dart';
import 'package:raven_front/widgets/front/loader.dart';

class pages {
  static Splash splash = Splash();
  static Loading loading = Loading();
  static ChangePassword changePassword = ChangePassword();
  static ChangeResume changeResume = ChangeResume();
  static Login login = Login();
  static Home home = Home();
  static Asset asset = Asset();
  static Transactions transactions = Transactions();
  static CreateNFTAsset createNFTAsset = CreateNFTAsset();
  static CreateMainAsset createMainAsset = CreateMainAsset();
  static CreateMainSubAsset createMainSubAsset = CreateMainSubAsset();
  static CreateQualifierAsset createQualifierAsset = CreateQualifierAsset();
  static CreateQualifierSubAsset createQualifierSubAsset =
      CreateQualifierSubAsset();
  static CreateChannelAsset createChannelAsset = CreateChannelAsset();
  static CreateRestrictedAsset createRestrictedAsset = CreateRestrictedAsset();
  static Checkout checkout = Checkout();
  static TransactionPage transaction = TransactionPage();
  static Receive receive = Receive();
  static Send send = Send();
  static About about = About();
  static Advanced advanced = Advanced();
  static Export export = Export();
  static Feedback feedback = Feedback();
  static Import import = Import();
  static Language language = Language();
  static Loader loader = Loader();
  static ElectrumNetwork electrumNetwork = ElectrumNetwork();
  static Preferences preferences = Preferences();
  static RemovePassword removePassword = RemovePassword();
  static Currency currency = Currency();
  static ScanQR scan = ScanQR();
  static Support support = Support();
  static BackupSeed backupShow = BackupSeed();
  static VerifySeed backupVerify = VerifySeed();
  static Security security = Security();
  static TechnicalView technicalView = TechnicalView();
  static WalletView walletView = WalletView();

  static Map<String, Widget Function(BuildContext)> routes(
          BuildContext context) =>
      {
        '/splash': (context) => splash,
        '/': (context) => loading,
        '/home': (context) => home,
        '/manage/asset': (context) => asset,
        '/transactions': (context) => transactions,
        '/wallet': (context) => walletView,
        '/loader': (context) => loader,
        '/scan': (context) => scan,
        '/create/nft': (context) => createNFTAsset,
        '/create/main': (context) => createMainAsset,
        '/create/sub': (context) => createMainSubAsset,
        '/create/qualifier': (context) => createQualifierAsset,
        '/create/qualifiersub': (context) => createQualifierSubAsset,
        '/create/channel': (context) => createChannelAsset,
        '/create/restricted': (context) => createRestrictedAsset,
        '/security/backup': (context) => backupShow,
        '/security/backupConfirm': (context) => backupVerify,
        '/security/change': (context) => changePassword,
        '/security/resume': (context) => changeResume,
        '/security/remove': (context) => removePassword,
        '/security/login': (context) => login,
        '/transaction/transaction': (context) => transaction,
        '/transaction/receive': (context) => receive,
        '/transaction/send': (context) => send,
        '/transaction/checkout': (context) => checkout,
        '/settings/export/export': (context) => checkout,
        '/settings/about': (context) => about,
        '/settings/level': (context) => advanced,
        '/settings/currency': (context) => language,
        '/settings/export': (context) => export,
        '/settings/feedback': (context) => feedback,
        '/settings/import': (context) => import,
        '/settings/network': (context) => electrumNetwork,
        '/settings/preferences': (context) => preferences,
        '/settings/security': (context) => security,
        '/settings/support': (context) => support,
        '/settings/technical': (context) => technicalView,
      };
}
