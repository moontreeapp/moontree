// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/cupertino.dart';
//import 'package:client_front/presentation/pagesv1/home/home.dart';
//import 'package:client_front/presentation/pagesv1/manage/assets.dart';
//import 'package:client_front/presentation/pagesv1/manage/create/nft.dart';
//import 'package:client_front/presentation/pagesv1/manage/create/main.dart';
//import 'package:client_front/presentation/pagesv1/manage/create/sub.dart';
//import 'package:client_front/presentation/pagesv1/manage/create/qualifier.dart';
//import 'package:client_front/presentation/pagesv1/manage/create/qualifiersub.dart';
//import 'package:client_front/presentation/pagesv1/manage/create/channel.dart';
//import 'package:client_front/presentation/pagesv1/manage/create/restricted.dart';
//import 'package:client_front/presentation/pagesv1/manage/reissue/restricted.dart';
//import 'package:client_front/presentation/pagesv1/manage/reissue/main.dart';
//import 'package:client_front/presentation/pagesv1/manage/reissue/sub.dart';
//import 'package:client_front/presentation/pagesv1/misc/scan.dart';
//import 'package:client_front/presentation/pagesv1/misc/checkout.dart';
//import 'package:client_front/presentation/pagesv1/security/backup/keypair.dart';
//import 'package:client_front/presentation/pagesv1/security/backup/intro.dart';
//import 'package:client_front/presentation/pagesv1/security/backup/show.dart';
//import 'package:client_front/presentation/pagesv1/security/backup/verify.dart';
//import 'package:client_front/presentation/pagesv1/security/create_choice.dart';
//import 'package:client_front/presentation/pagesv1/security/create_native.dart';
//import 'package:client_front/presentation/pagesv1/security/create_password.dart';
//import 'package:client_front/presentation/pagesv1/security/login_password.dart';
//import 'package:client_front/presentation/pagesv1/security/login_native.dart';
//import 'package:client_front/presentation/pagesv1/security/resume.dart';
//import 'package:client_front/presentation/pagesv1/security/change_password.dart';
//import 'package:client_front/presentation/pagesv1/security/change_method.dart';
//import 'package:client_front/presentation/pagesv1/settings/about.dart';
//import 'package:client_front/presentation/pagesv1/settings/advanced.dart';
//import 'package:client_front/presentation/pagesv1/settings/export.dart';
//import 'package:client_front/presentation/pagesv1/settings/feedback.dart';
//import 'package:client_front/presentation/pagesv1/settings/import.dart';
//import 'package:client_front/presentation/pagesv1/settings/language.dart';
//import 'package:client_front/presentation/pagesv1/settings/network.dart';
//import 'package:client_front/presentation/pagesv1/settings/mining.dart';
//import 'package:client_front/presentation/pagesv1/settings/database.dart';
//import 'package:client_front/presentation/pagesv1/settings/developer.dart';
//import 'package:client_front/presentation/pagesv1/settings/userlevel.dart';
//import 'package:client_front/presentation/pagesv1/settings/preferences.dart';
//import 'package:client_front/presentation/pagesv1/settings/support.dart';
//import 'package:client_front/presentation/pagesv1/settings/sweep.dart';
//import 'package:client_front/presentation/pagesv1/settings/technical.dart';
//import 'package:client_front/presentation/pagesv1/settings/addresses.dart';
////import 'package:client_front/pages/settings/currency.dart';
////import 'package:client_front/pages/settings/wallet.dart';
//import 'package:client_front/presentation/pagesv1/wallet/receive.dart';
//import 'package:client_front/presentation/pagesv1/wallet/send.dart';
//import 'package:client_front/presentation/pagesv1/wallet/transaction.dart';
////import 'package:client_front/pages/wallet/transactions.dart';
//import 'package:client_front/presentation/pagesv1/wallet/transactions/widget.dart';
//import 'package:client_front/presentation/widgets/front/verify.dart';
// v3
import 'package:client_front/presentation/pages/splash.dart';
import 'package:client_front/presentation/pages/login/login.dart';
import 'package:client_front/presentation/pages/wallet/wallet.dart';
import 'package:client_front/presentation/pages/backup/backup.dart';
import 'package:client_front/presentation/pages/restore/restore.dart';

final _staticRoutes = <String, Widget Function(BuildContext)>{
  //'/home': (BuildContext context) => const Home(),
  //'/manage/asset': (BuildContext context) => const AssetPage(),
  //'/transactions': (BuildContext context) => const Transactions(),
  //'/addresses': (BuildContext context) => const WalletView(), // technical view
  //'/scan': (BuildContext context) => const ScanQR(),
  //// create and reissue would make better sense if it referenced assets,
  //// but actually these should all be improved to match
  //// /wallet or /manage or /swap anyway...
  //'/create/nft': (BuildContext context) => CreateNFTAsset(),
  //'/create/main': (BuildContext context) => CreateMainAsset(),
  //'/create/sub': (BuildContext context) => CreateMainSubAsset(),
  //'/create/qualifier': (BuildContext context) => CreateQualifierAsset(),
  //'/create/qualifiersub': (BuildContext context) => CreateQualifierSubAsset(),
  //'/create/channel': (BuildContext context) => CreateChannelAsset(),
  //'/create/restricted': (BuildContext context) => CreateRestrictedAsset(),
  //'/create/checkout': (BuildContext context) => const Checkout(
  //      transactionType: TransactionType.create,
  //    ),
  //'/reissue/main': (BuildContext context) => ReissueMainAsset(),
  //'/reissue/sub': (BuildContext context) => ReissueMainSubAsset(),
  //'/reissue/restricted': (BuildContext context) => ReissueRestrictedAsset(),
  //'/reissue/checkout': (BuildContext context) => const Checkout(
  //      transactionType: TransactionType.reissue,
  //    ),
  //'/security/backup/backupintro': (BuildContext context) => const BackupIntro(),
  //'/security/backup': (BuildContext context) => const BackupSeed(),
  //'/security/backupKeypair': (BuildContext context) => const ShowKeypair(),
  //'/security/backupConfirm': (BuildContext context) => const VerifySeed(),
  //'/security/password/change': (BuildContext context) => ChangeLoginPassword(),
  //'/security/method/change': (BuildContext context) => ChangeLoginMethod(),
  //'/security/resume': (BuildContext context) => ChangeResume(),
  //'/security/password/login': (BuildContext context) => LoginPassword(),
  //'/security/native/login': (BuildContext context) => LoginNative(),
  //'/security/create/setup': (BuildContext context) => const CreateChoice(),
  //'/security/password/createlogin': (BuildContext context) =>
  //    const CreatePassword(),
  //'/security/native/createlogin': (BuildContext context) =>
  //    const CreateNative(),
  //'/security/security': (BuildContext context) => const VerifyAuthentication(),
  //'/transaction/transaction': (BuildContext context) => const TransactionPage(),
  //'/transaction/receive': (BuildContext context) => const Receive(),
  //'/transaction/send': (BuildContext context) => const Send(),
  //'/transaction/checkout': (BuildContext context) => const Checkout(
  //      transactionType: TransactionType.spend,
  //    ),
  //'/settings/export/export': (BuildContext context) =>
  //    const Checkout(transactionType: TransactionType.export),
  //'/settings/about': (BuildContext context) => About(),
  //'/settings/level': (BuildContext context) => const Advanced(),
  //'/settings/currency': (BuildContext context) => Language(),
  //'/settings/export': (BuildContext context) => const Export(),
  //'/settings/feedback': (BuildContext context) => const Feedback(),
  //'/settings/import': (BuildContext context) => const Import(),
  ////'/settings/network': (context) => ElectrumNetwork(),
  //'/settings/network/mining': (BuildContext context) => const MiningChoice(),
  ////'/settings/network/blockchain': (context) => BlockchainChoices(),
  //'/settings/network/blockchain': (BuildContext context) =>
  //    const ElectrumNetworkPage(),
  //'/settings/preferences': (BuildContext context) => Preferences(),
  //'/settings/support': (BuildContext context) => Support(),
  //'/settings/technical': (BuildContext context) => const TechnicalView(),
  //'/settings/database': (BuildContext context) => const DatabaseOptions(),
  //'/settings/developer': (BuildContext context) => const DeveloperOptions(),
  //'/settings/advanced': (BuildContext context) =>
  //    const AdvancedDeveloperOptions(),
  //'/settings/sweep': (BuildContext context) => SweepPage(),
  //v3
  '/': (BuildContext context) => const PreLogin(),
  '/splash': (BuildContext context) => const Splash(),
  '/login/create': (BuildContext context) => const LoginCreate(),
  '/login/create/native': (BuildContext context) => const LoginCreateNative(),
  '/login/create/resume': (BuildContext context) => const CreateResume(),
  '/login/create/password': (BuildContext context) =>
      const LoginCreatePassword(),
  '/login/native': (BuildContext context) => const LoginNative(),
  '/login/password': (BuildContext context) => const LoginPassword(),
  '/wallet/holdings': (BuildContext context) => const WalletHoldings(),
  '/backup/intro': (BuildContext context) => const BackupIntro(),
  '/backup/keypair': (BuildContext context) => const ShowKeypair(),
  '/backup/seed': (BuildContext context) => const BackupSeed(),
  '/backup/verify': (BuildContext context) => const VerifySeed(),
  '/restore/import': (BuildContext context) => const ImportPage(),
  //'/restore/export': (BuildContext context) => const Export(),
};

Map<String, Widget Function(BuildContext)> get routes => _staticRoutes;

/// unused solution in preference to named routes
//import 'package:client_front/presentation/utils/animation.dart';
//Route<dynamic>? generatedRoutes(RouteSettings settings) {
//  switch (settings.name) {
//    case '/':
//      return FadeFirstTransition(child: LoginCreate());
//    case '/login/create':
//      return FadeFirstTransition(child: LoginCreate());
//    case '/login/create/native':
//      return FadeFirstTransition(child: LoginCreateNative());
//    case '/login/native':
//      return FadeFirstTransition(child: LoginNative());
//    default:
//      return null;
//  }
//}
//