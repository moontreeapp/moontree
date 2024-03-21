import 'package:moontree/cubits/cubits.dart';

class GlobalCubits {
  /// sections
  final walletLayer = WalletLayerCubit();

  /// feeds
  final walletFeed = WalletFeedCubit();

  /// layers
  final appLayer = AppLayerCubit();
  final navbar = NavbarCubit();
  final tutorial = TutorialCubit();
  final toast = ToastCubit();
  final panel = PanelCubit();

  GlobalCubits();
}

final GlobalCubits cubits = GlobalCubits();
