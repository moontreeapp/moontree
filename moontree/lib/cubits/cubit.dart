import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubits.dart';

class GlobalCubits {
  /// sections
  final wallet = WalletCubit();
  final transactions = TransactionsCubit();

  /// layers
  final appLayer = AppLayerCubit();
  final pane = PaneCubit();
  final appbar = AppbarCubit();
  final navbar = NavbarCubit();
  final toast = ToastCubit();
  final ignore = IgnoreCubit();
  final panel = PanelCubit();
  final tutorial = TutorialCubit();

  /// combined
  List<Cubit> get all => [
        wallet,
        transactions,
        appLayer,
        pane,
        appbar,
        navbar,
        toast,
        ignore,
        panel,
        tutorial,
      ];

  GlobalCubits();
}

final GlobalCubits cubits = GlobalCubits();
