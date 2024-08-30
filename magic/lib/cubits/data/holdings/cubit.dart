import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/holding.dart';

part 'state.dart';

class HoldingsCubit extends UpdatingCubit<HoldingsState> {
  HoldingsCubit() : super(const HoldingsState());
  @override
  String get key => 'holdings';
  @override
  void reset() => emit(const HoldingsState());

  @override
  void update({
    Set<Holding>? holdings,
    int? height,
    bool? isSubmitting,
    HoldingsState? prior,
  }) {
    emit(HoldingsState(
      holdings: holdings ?? state.holdings,
      height: height ?? state.height,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: prior ?? state.withoutPrior,
    ));
  }

  Holding getHolding({
    required String symbol,
    required Blockchain blockchain,
  }) =>
      state.holdings.firstWhere((holding) =>
          holding.symbol == symbol && holding.blockchain == blockchain);

  Holding getHoldingFrom({required Holding holding}) =>
      state.holdings.firstWhere((h) =>
          h.symbol == holding.symbol && h.blockchain == holding.blockchain);
}
