part of 'cubit.dart';

enum Section { login, wallet, manage, swap, settings, scan }

/// describes where we are at in the app
abstract class LocationCubitState extends Equatable {
  /// what page are they on?
  final String? path;

  /// what section of the app am I in?
  final Section? section;

  /// what section of the app am I in?
  final Section? sector; // wallet / manage / swap

  /// what asset I'm looking at currently
  final String? symbol;

  /// should replace Current.wallet not included yet because so many back processes need access to it still.
  // final Wallet? wallet;
  // final ChainNet? chainNet; // what chain net am I connected to

  /// the menu (on the home page) is open
  final bool menuOpen;

  final bool dataTab; // if we open the data tab on wallet holding

  final bool submitting;

  const LocationCubitState({
    this.path,
    this.section,
    this.sector,
    this.symbol,
    this.menuOpen = false,
    this.dataTab = false,
    this.submitting = false,
  });
  // would like to enforce it here but we can't because const can't have body
  //  {
  //    sector = sectorSections.contains(this.sector)
  //    ? this.sector
  //    : Section.wallet;
  //  }
  // or
  //  {
  //    if (!sectorSections.contains(this.sector)) {
  //      throw Exception('invalid sector');
  //    }
  //  }

  static List<Section> get sectorSections =>
      [Section.wallet, Section.manage, Section.swap];

  @override
  List<Object?> get props =>
      [path, section, sector, symbol, menuOpen, dataTab, submitting];

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

  bool get loggedOut => [
        null,
        '',
        '/',
        '/splash',
        '/login/create',
        '/login/create/native',
        '/login/create/resume',
        '/login/create/password',
        '/login/native',
        '/login/password',
      ].contains(path);

  bool get searchButtonShown => path == '/wallet/holdings' && !menuOpen;
}

class LocationState extends LocationCubitState {
  const LocationState({
    super.path,
    super.section,
    super.sector,
    super.symbol,
    super.menuOpen,
    super.dataTab,
    super.submitting,
  });
}
