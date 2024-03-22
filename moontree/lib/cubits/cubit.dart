import 'package:moontree/cubits/cubits.dart';

class GlobalCubits {
  /// sections
  final walletLayer = WalletLayerCubit();
  final transactionsLayer = TransactionsLayerCubit();

  /// feeds
  final walletFeed = WalletFeedCubit();
  final transactionsFeed = TransactionsFeedCubit();

  /// layers
  final appLayer = AppLayerCubit();
  final pane = PaneCubit();
  final appbar = AppbarCubit();
  final navbar = NavbarCubit();
  final toast = ToastCubit();
  final panel = PanelCubit();
  final tutorial = TutorialCubit();

  GlobalCubits();
}

final GlobalCubits cubits = GlobalCubits();
