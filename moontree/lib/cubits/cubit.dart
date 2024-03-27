import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubits.dart';
import 'package:provider/single_child_widget.dart' show SingleChildWidget;

class GlobalCubits {
  /// canvas
  final canvas = CanvasCubit();
  final menu = MenuCubit();
  final holding = HoldingCubit();

  /// pane
  final pane = PaneCubit();
  final wallet = WalletCubit();
  final transactions = TransactionsCubit();
  final fade = FadeCubit();

  /// other
  final appbar = AppbarCubit();
  final app = AppCubit();
  final navbar = NavbarCubit();
  final panel = PanelCubit();
  final toast = ToastCubit();
  final tutorial = TutorialCubit();
  final ignore = IgnoreCubit();

  /// combined
  List<Cubit> get all => [
        canvas,
        menu,
        pane,
        wallet,
        transactions,
        fade,
        appbar,
        app,
        navbar,
        panel,
        toast,
        tutorial,
        ignore,
      ];

  List<SingleChildWidget> get providers => [
        BlocProvider<CanvasCubit>(create: (context) => canvas),
        BlocProvider<MenuCubit>(create: (context) => menu),
        BlocProvider<HoldingCubit>(create: (context) => holding),
        BlocProvider<PaneCubit>(create: (context) => pane),
        BlocProvider<WalletCubit>(create: (context) => wallet),
        BlocProvider<TransactionsCubit>(create: (context) => transactions),
        BlocProvider<FadeCubit>(create: (context) => fade),
        BlocProvider<AppCubit>(create: (context) => app),
        BlocProvider<AppbarCubit>(create: (context) => appbar),
        BlocProvider<NavbarCubit>(create: (context) => navbar),
        BlocProvider<ToastCubit>(create: (context) => toast),
        BlocProvider<PanelCubit>(create: (context) => panel),
        BlocProvider<TutorialCubit>(create: (context) => tutorial),
        BlocProvider<IgnoreCubit>(create: (context) => ignore),
      ];

  GlobalCubits();
}

final GlobalCubits cubits = GlobalCubits();
