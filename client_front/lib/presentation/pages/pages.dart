// ignore_for_file: avoid_classes_with_only_static_members

import 'package:client_front/presentation/pages/wallet/checkout.dart';
import 'package:flutter/cupertino.dart';
import 'package:client_front/presentation/pages/home/home.dart';
import 'package:client_front/presentation/pages/manage/assets.dart';
import 'package:client_front/presentation/pages/manage/create/nft.dart';
import 'package:client_front/presentation/pages/manage/create/main.dart';
import 'package:client_front/presentation/pages/manage/create/sub.dart';
import 'package:client_front/presentation/pages/manage/create/qualifier.dart';
import 'package:client_front/presentation/pages/manage/create/qualifiersub.dart';
import 'package:client_front/presentation/pages/manage/create/channel.dart';
import 'package:client_front/presentation/pages/manage/create/restricted.dart';
import 'package:client_front/presentation/pages/manage/reissue/restricted.dart';
import 'package:client_front/presentation/pages/manage/reissue/main.dart';
import 'package:client_front/presentation/pages/manage/reissue/sub.dart';
import 'package:client_front/presentation/pages/misc/splash.dart';
import 'package:client_front/presentation/pages/misc/scan.dart';
import 'package:client_front/presentation/pages/misc/checkout.dart';
import 'package:client_front/presentation/pages/security/backup/keypair.dart';
import 'package:client_front/presentation/pages/security/backup/intro.dart';
import 'package:client_front/presentation/pages/security/backup/show.dart';
import 'package:client_front/presentation/pages/security/backup/verify.dart';
import 'package:client_front/presentation/pages/security/create_choice.dart';
import 'package:client_front/presentation/pages/security/create_native.dart';
import 'package:client_front/presentation/pages/security/create_password.dart';
import 'package:client_front/presentation/pages/security/login_password.dart';
import 'package:client_front/presentation/pages/security/login_native.dart';
import 'package:client_front/presentation/pages/security/resume.dart';
import 'package:client_front/presentation/pages/security/change_password.dart';
import 'package:client_front/presentation/pages/security/change_method.dart';
import 'package:client_front/presentation/pages/settings/about.dart';
import 'package:client_front/presentation/pages/settings/advanced.dart';
import 'package:client_front/presentation/pages/settings/export.dart';
import 'package:client_front/presentation/pages/settings/feedback.dart';
import 'package:client_front/presentation/pages/settings/import.dart';
import 'package:client_front/presentation/pages/settings/language.dart';
import 'package:client_front/presentation/pages/settings/network.dart';
import 'package:client_front/presentation/pages/settings/mining.dart';
import 'package:client_front/presentation/pages/settings/database.dart';
import 'package:client_front/presentation/pages/settings/developer.dart';
import 'package:client_front/presentation/pages/settings/userlevel.dart';
import 'package:client_front/presentation/pages/settings/preferences.dart';
import 'package:client_front/presentation/pages/settings/support.dart';
import 'package:client_front/presentation/pages/settings/sweep.dart';
import 'package:client_front/presentation/pages/settings/technical.dart';
import 'package:client_front/presentation/pages/settings/addresses.dart';
//import 'package:client_front/pages/settings/currency.dart';
//import 'package:client_front/pages/settings/wallet.dart';
import 'package:client_front/presentation/pages/wallet/receive.dart';
import 'package:client_front/presentation/pages/wallet/send.dart';
import 'package:client_front/presentation/pages/wallet/transaction.dart';
//import 'package:client_front/pages/wallet/transactions.dart';
import 'package:client_front/presentation/pages/wallet/transactions/widget.dart';
import 'package:client_front/presentation/widgets/front/verify.dart';

class pages {
  static final staticRoutes = <String, Widget Function(BuildContext)>{
    '/splash': (BuildContext context) => const Splash(),
    '/home': (BuildContext context) => const Home(),
    '/manage/asset': (BuildContext context) => const AssetPage(),
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
    '/create/qualifiersub': (BuildContext context) => CreateQualifierSubAsset(),
    '/create/channel': (BuildContext context) => CreateChannelAsset(),
    '/create/restricted': (BuildContext context) => CreateRestrictedAsset(),
    '/create/checkout': (BuildContext context) => const Checkout(
          transactionType: TransactionType.create,
        ),
    '/reissue/main': (BuildContext context) => ReissueMainAsset(),
    '/reissue/sub': (BuildContext context) => ReissueMainSubAsset(),
    '/reissue/restricted': (BuildContext context) => ReissueRestrictedAsset(),
    '/reissue/checkout': (BuildContext context) => const Checkout(
          transactionType: TransactionType.reissue,
        ),
    '/security/backup/backupintro': (BuildContext context) =>
        const BackupIntro(),
    '/security/backup': (BuildContext context) => const BackupSeed(),
    '/security/backupKeypair': (BuildContext context) => const ShowKeypair(),
    '/security/backupConfirm': (BuildContext context) => const VerifySeed(),
    '/security/password/change': (BuildContext context) =>
        ChangeLoginPassword(),
    '/security/method/change': (BuildContext context) => ChangeLoginMethod(),
    '/security/resume': (BuildContext context) => ChangeResume(),
    '/security/password/login': (BuildContext context) => LoginPassword(),
    '/security/native/login': (BuildContext context) => LoginNative(),
    '/security/create/setup': (BuildContext context) => const CreateChoice(),
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
    '/settings/network/mining': (BuildContext context) => const MiningChoice(),
    //'/settings/network/blockchain': (context) => BlockchainChoices(),
    '/settings/network/blockchain': (BuildContext context) =>
        const ElectrumNetworkPage(),
    '/settings/preferences': (BuildContext context) => Preferences(),
    '/settings/support': (BuildContext context) => Support(),
    '/settings/technical': (BuildContext context) => const TechnicalView(),
    '/settings/database': (BuildContext context) => const DatabaseOptions(),
    '/settings/developer': (BuildContext context) => const DeveloperOptions(),
    '/settings/advanced': (BuildContext context) =>
        const AdvancedDeveloperOptions(),
    '/settings/sweep': (BuildContext context) => SweepPage(),
    '/send/checkout': (BuildContext context) => SimpleSendCheckout(
          transactionType: TransactionType.spend,
        ),
  };

  static Map<String, Widget Function(BuildContext)> get routes => staticRoutes;
}
