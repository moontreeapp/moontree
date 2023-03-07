part of 'cubit.dart';

enum Section { wallet, manage, swap }

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
  const LocationCubitState({
    this.path,
    this.section,
    this.symbol,
  });

  @override
  List<Object?> get props => [path, section, symbol];

  /// these path through functions allow this to be the single source of truth,
  /// for the rest of the front end. Todo: convert frontend to reference this.
  Wallet get wallet => Current.wallet;
  ChainNet get chainNet => Current.chainNet;
  String get settingsPath => components.cubits.backContainer.state.path;
}

class LocationState extends LocationCubitState {
  const LocationState({
    super.path,
    super.section,
    super.symbol,
  });
}
