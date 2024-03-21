import 'package:moontree/cubits/cubits.dart';

class GlobalCubits {
  /// primary pages
  final appLayer = AppLayerCubit();
  final walletLayer = WalletLayerCubit();

  /// secondary pages
  final walletFeed = WalletFeedCubit();

  /// layers
  final navbar = NavbarCubit();
  final tutorial = TutorialCubit();
  final toast = ToastCubit();
  final panel = PanelCubit();

  /// navbar
  final gallery = GalleryCubit();

  GlobalCubits();
}

final GlobalCubits cubits = GlobalCubits();
