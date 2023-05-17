// ignore_for_file: avoid_classes_with_only_static_members

import 'package:client_front/presentation/pages/wallet/scan.dart';
import 'package:flutter/material.dart';
import 'package:client_front/presentation/pages/splash.dart';
import 'package:client_front/presentation/pages/login/login.dart';
import 'package:client_front/presentation/pages/wallet/wallet.dart';
import 'package:client_front/presentation/pages/manage/manage.dart';
import 'package:client_front/presentation/pages/backup/backup.dart';
import 'package:client_front/presentation/pages/restore/restore.dart';
import 'package:client_front/presentation/pages/settings/settings.dart';
import 'package:client_front/presentation/pages/support/support.dart';
import 'package:client_front/presentation/widgets/front/verify.dart';

final _staticRoutes = <String, Widget Function(BuildContext)>{
  '/': (BuildContext context) => const PreLogin(),
  '/splash': (BuildContext context) => const Splash(),
  '/login/create': (BuildContext context) => const LoginCreate(),
  '/login/create/native': (BuildContext context) => const LoginCreateNative(),
  '/login/create/resume': (BuildContext context) => const CreateResume(),
  '/login/create/password': (BuildContext context) =>
      const LoginCreatePassword(),
  '/login/native': (BuildContext context) => const LoginNative(),
  '/login/password': (BuildContext context) => const LoginPassword(),
  '/login/verify': (BuildContext context) => const VerifyAuthentication(),
  '/login/modify/password': (BuildContext context) =>
      const ChangeLoginPassword(),
  '/receive': (BuildContext context) => const Receive(),
  '/wallet/holdings': (BuildContext context) => const WalletHoldings(),
  '/wallet/holding': (BuildContext context) => const WalletHolding(),
  '/wallet/holding/transaction': (BuildContext context) =>
      const TransactionPage(),
  '/wallet/send': (BuildContext context) => const SimpleSend(),
  '/wallet/send/checkout': (BuildContext context) =>
      SimpleSendCheckout(transactionType: TransactionType.spend),
  '/manage/holdings': (BuildContext context) => const ManageHoldings(),
  '/manage/holding': (BuildContext context) => const ManageHolding(),
  '/manage/create': (BuildContext context) => const SimpleCreate(),
  '/manage/create/checkout': (BuildContext context) =>
      const SimpleCreateCheckout(),
  '/manage/reissue': (BuildContext context) => const SimpleReissue(),
  '/manage/reissue/checkout': (BuildContext context) =>
      SimpleReissueCheckout(transactionType: ReissueTransactionType.reissue),
  '/backup/intro': (BuildContext context) => const BackupIntro(),
  '/backup/keypair': (BuildContext context) => const ShowKeypair(),
  '/backup/seed': (BuildContext context) => const BackupSeed(),
  '/backup/verify': (BuildContext context) => const VerifySeed(),
  '/restore/import': (BuildContext context) => const ImportPage(),
  //'/restore/export': (BuildContext context) => const Export(),
  '/support/about': (BuildContext context) => const About(),
  '/support/support': (BuildContext context) => const SupportPage(),
  '/mode/developer': (BuildContext context) => const DeveloperMode(),
  '/mode/advanced': (BuildContext context) => const AdvancedDeveloperMode(),
  '/setting/database': (BuildContext context) => const DatabaseSettings(),
  '/setting/mining': (BuildContext context) => const MiningSetting(),
  '/setting/security': (BuildContext context) => const SecuritySettings(),
  '/network/blockchain': (BuildContext context) => const BlockchainSettings(),
  '/scan': (BuildContext context) => const ScanQRPage(),
  '/send/checkout': (BuildContext context) => SimpleSendCheckout(
        transactionType: TransactionType.spend,
      ),
};

Map<String, Widget Function(BuildContext)> get routes => _staticRoutes;
