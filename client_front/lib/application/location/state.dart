part of 'cubit.dart';

enum Section { login, wallet, manage, swap, settings }

/// describes where we are at in the app
abstract class LocationCubitState extends Equatable {
  /// what page are they on?
  final String? path;

  /// what section of the app am I in?
  final Section? section;

  /// what asset I'm looking at currently
  final String? symbol;

  /// should replace Current.wallet not included yet because so many back processes need access to it still.
  // final Wallet? wallet;
  // final ChainNet? chainNet; // what chain net am I connected to

  /// the menu (on the home page) is open
  final bool menuOpen;

  const LocationCubitState({
    this.path,
    this.section,
    this.symbol,
    this.menuOpen = false,
  });

  @override
  List<Object?> get props => [path, section, symbol, menuOpen];

  /// these path through functions allow this to be the single source of truth,
  /// for the rest of the front end. Todo: convert frontend to reference this.
  Wallet get wallet => Current.wallet;
  ChainNet get chainNet => Current.chainNet;
  //String get menuPath => components.cubits.backContainer.state.path;

  Security get security => symbol == null
      ? Current.coin
      : Security(
          symbol: symbol!,
          chain: pros.settings.chain,
          net: pros.settings.net,
        );
}

class LocationState extends LocationCubitState {
  const LocationState({
    super.path,
    super.section,
    super.symbol,
    super.menuOpen,
  });
}
