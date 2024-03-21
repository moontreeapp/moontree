import 'package:moontree/cubits/cubits.dart';

class GlobalCubits {
  /// sections
  final walletLayer = WalletLayerCubit();

  /// feeds
  final walletFeed = WalletFeedCubit();

  /// layers
  final appLayer = AppLayerCubit();
  final appbar = AppbarCubit();
  final navbar = NavbarCubit();
  final toast = ToastCubit();
  final panel = PanelCubit();
  final tutorial = TutorialCubit();

  GlobalCubits();
}

final GlobalCubits cubits = GlobalCubits();
