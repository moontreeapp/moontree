import 'package:flutter/cupertino.dart';
import 'package:raven_front/pages/account/home.dart';
import 'package:raven_front/pages/account/transactions.dart';
import 'package:raven_front/pages/misc/loading.dart';
import 'package:raven_front/pages/misc/scan.dart';
import 'package:raven_front/pages/security/login.dart';
import 'package:raven_front/pages/security/resume.dart';
import 'package:raven_front/pages/security/change.dart';
import 'package:raven_front/pages/settings/about.dart';
import 'package:raven_front/pages/settings/currency.dart';
import 'package:raven_front/pages/settings/export.dart';
import 'package:raven_front/pages/settings/import.dart';
import 'package:raven_front/pages/settings/import_export.dart';
import 'package:raven_front/pages/settings/language.dart';
import 'package:raven_front/pages/settings/network.dart';
import 'package:raven_front/pages/settings/preferences.dart';
import 'package:raven_front/pages/settings/settings.dart';
import 'package:raven_front/pages/settings/security.dart';
import 'package:raven_front/pages/settings/support.dart';
import 'package:raven_front/pages/settings/technical.dart';
import 'package:raven_front/pages/transaction/create.dart';
import 'package:raven_front/pages/transaction/receive.dart';
import 'package:raven_front/pages/transaction/send.dart';
import 'package:raven_front/pages/transaction/transaction.dart';
import 'package:raven_front/pages/wallet/wallet.dart';
import 'package:raven_front/widgets/front/loader.dart';

class pages {
  static Loading loading = Loading();
  static ChangePassword changePassword = ChangePassword();
  static ChangeResume changeResume = ChangeResume();
  static Login login = Login();
  static Home home = Home();
  static Transactions transactions = Transactions();
  static TransactionPage transaction = TransactionPage();
  static Receive receive = Receive();
  static Send send = Send();
  static CreateAsset createAsset = CreateAsset();
  static About about = About();
  static Language language = Language();
  static Export export = Export();
  static Import import = Import();
  static ImportExport importExport = ImportExport();
  static Loader loader = Loader();
  static ElectrumNetwork electrumNetwork = ElectrumNetwork();
  static Preferences preferences = Preferences();
  static Settings settings = Settings();
  static Currency currency = Currency();
  static ScanQR scan = ScanQR();
  static Support support = Support();
  static Security security = Security();
  static TechnicalView technicalView = TechnicalView();
  static WalletView walletView = WalletView();

  static Map<String, Widget Function(BuildContext)> routes(
          BuildContext context) =>
      {
        '/': (context) => loading,
        '/home': (context) => home,
        '/transactions': (context) => transactions,
        '/wallet': (context) => walletView,
        '/loader': (context) => loader,
        '/scan': (context) => scan,
        '/security/change': (context) => changePassword,
        '/security/resume': (context) => changeResume,
        '/security/login': (context) => login,
        '/transaction/transaction': (context) => transaction,
        '/transaction/receive': (context) => receive,
        '/transaction/send': (context) => send,
        '/transaction/create': (context) => createAsset,
        '/settings/about': (context) => about,
        //'/settings/advanced': (context) => advanced,
        '/settings/currency': (context) => language,
        '/settings/export': (context) => export,
        '/settings/import': (context) => import,
        '/settings/import_export': (context) => importExport,
        '/settings/network': (context) => electrumNetwork,
        '/settings/preferences': (context) => preferences,
        '/settings/settings': (context) => settings,
        '/settings/security': (context) => security,
        '/settings/support': (context) => support,
        '/settings/technical': (context) => technicalView,
      };
}
