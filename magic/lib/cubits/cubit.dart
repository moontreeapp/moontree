import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/cubits.dart';
import 'package:magic/cubits/menu/cubit.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:provider/single_child_widget.dart' show SingleChildWidget;

class GlobalCubits {
  /// canvas
  final canvas = CanvasCubit();
  final balance = BalanceCubit();
  final oldmenu = OldMenuCubit();
  final menu = MenuCubit();
  final holding = HoldingCubit();

  /// pane
  final pane = PaneCubit();
  final wallet = WalletCubit();
  final transactions = TransactionsCubit();
  final transaction = TransactionCubit();
  final send = SendCubit();
  final receive = ReceiveCubit();
  final swap = SwapCubit();
  final manage = ManageCubit();
  final fade = FadeCubit();

  /// other - ui
  final appbar = AppbarCubit();
  final navbar = NavbarCubit();
  final panel = PanelCubit();
  final welcome = WelcomeCubit();
  final toast = ToastCubit();
  final tutorial = TutorialCubit();
  final ignore = IgnoreCubit();

  /// other - state
  final app = AppCubit();
  final keys = KeysCubit();
  final holdings = HoldingsCubit();

  /// combined
  List<Cubit> get all => [
        canvas,
        oldmenu,
        menu,
        pane,
        wallet,
        transactions,
        fade,
        appbar,
        navbar,
        panel,
        toast,
        tutorial,
        ignore,
        app,
        keys,
        holdings,
        welcome,
      ];
  List<UpdatableCubit> get paneCubits =>
      [wallet, transactions, transaction, send, receive, swap, manage];

  List<SingleChildWidget> get providers => [
        BlocProvider<CanvasCubit>(create: (context) => canvas),
        BlocProvider<BalanceCubit>(create: (context) => balance),
        BlocProvider<OldMenuCubit>(create: (context) => oldmenu),
        BlocProvider<MenuCubit>(create: (context) => menu),
        BlocProvider<HoldingCubit>(create: (context) => holding),
        BlocProvider<PaneCubit>(create: (context) => pane),
        BlocProvider<WalletCubit>(create: (context) => wallet),
        BlocProvider<SwapCubit>(create: (context) => swap),
        BlocProvider<TransactionCubit>(create: (context) => transaction),
        BlocProvider<TransactionsCubit>(create: (context) => transactions),
        BlocProvider<ReceiveCubit>(create: (context) => receive),
        BlocProvider<SendCubit>(create: (context) => send),
        BlocProvider<ManageCubit>(create: (context) => manage),
        BlocProvider<FadeCubit>(create: (context) => fade),
        BlocProvider<AppbarCubit>(create: (context) => appbar),
        BlocProvider<NavbarCubit>(create: (context) => navbar),
        BlocProvider<ToastCubit>(create: (context) => toast),
        BlocProvider<PanelCubit>(create: (context) => panel),
        BlocProvider<TutorialCubit>(create: (context) => tutorial),
        BlocProvider<IgnoreCubit>(create: (context) => ignore),
        BlocProvider<AppCubit>(create: (context) => app),
        BlocProvider<KeysCubit>(create: (context) => keys),
        BlocProvider<HoldingsCubit>(create: (context) => holdings),
        BlocProvider<WelcomeCubit>(create: (context) => welcome),
      ];

  GlobalCubits();
}

final GlobalCubits cubits = GlobalCubits();
