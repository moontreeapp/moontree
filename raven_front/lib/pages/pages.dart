import 'package:flutter/cupertino.dart';
import 'package:raven_front/pages/account/home.dart';
import 'package:raven_front/pages/account/transactions.dart';
import 'package:raven_front/pages/loading.dart';
import 'package:raven_front/pages/password/login.dart';
import 'package:raven_front/pages/password/resume.dart';
import 'package:raven_front/pages/password/change.dart';
import 'package:raven_front/pages/settings/about.dart';
import 'package:raven_front/pages/settings/currency.dart';
import 'package:raven_front/pages/settings/export.dart';
import 'package:raven_front/pages/settings/import.dart';
import 'package:raven_front/pages/settings/language.dart';
import 'package:raven_front/pages/settings/network.dart';
import 'package:raven_front/pages/settings/preferences.dart';
import 'package:raven_front/pages/settings/settings.dart';
import 'package:raven_front/pages/settings/support.dart';
import 'package:raven_front/pages/settings/technical.dart';
import 'package:raven_front/pages/transaction/create.dart';
import 'package:raven_front/pages/transaction/receive.dart';
import 'package:raven_front/pages/transaction/send.dart';
import 'package:raven_front/pages/transaction/transaction.dart';
import 'package:raven_front/pages/wallet/wallet.dart';

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
  static ElectrumNetwork electrumNetwork = ElectrumNetwork();
  static Preferences preferences = Preferences();
  static Settings settings = Settings();
  static Currency currency = Currency();
  static Support support = Support();
  static TechnicalView technicalView = TechnicalView();
  static WalletView walletView = WalletView();
  static Map<String, Widget Function(BuildContext)> routes(
          BuildContext context) =>
      {
        '/': (context) => loading,
        '/password/change': (context) => changePassword,
        '/password/resume': (context) => changeResume,
        '/login': (context) => login,
        '/home': (context) => home,
        '/transactions': (context) => transactions,
        '/transaction': (context) => transaction,
        '/receive': (context) => receive,
        '/send': (context) => send,
        '/create': (context) => createAsset,
        '/settings/about': (context) => about,
        '/settings/currency': (context) => language,
        '/settings/export': (context) => export,
        '/settings/import': (context) => import,
        '/settings/network': (context) => electrumNetwork,
        '/settings/preferences': (context) => preferences,
        '/settings/settings': (context) => settings,
        '/settings/support': (context) => support,
        '/settings/technical': (context) => technicalView,
        '/settings/wallet': (context) => walletView,
      };
}
