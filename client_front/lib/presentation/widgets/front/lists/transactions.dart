import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/records/types/transaction_view.dart';
import 'package:client_back/server/src/protocol/comm_transaction_view.dart';
import 'package:client_back/services/transaction/transaction.dart';
import 'package:client_front/presentation/components/components.dart';
import 'package:client_front/application/cubits.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:flutter/semantics.dart';

class TransactionList extends StatefulWidget {
  final TransactionsViewCubit? cubit;
  final Iterable<TransactionView>? transactions;
  final String? symbol;
  final String? msg;
  final ScrollController? scrollController;

  const TransactionList({
    this.cubit,
    this.transactions,
    this.symbol,
    this.msg,
    this.scrollController,
    Key? key,
  }) : super(key: key);

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  //widget.currentAccountId //  we don't rebuild on this, we're given it.
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  late Iterable<TransactionView> transactions;
  bool showUSD = false;
  Rate? rateUSD;
  int transactionCount = 1;

  @override
  void initState() {
    super.initState();
    listeners.add(
        pros.vouts.batchedChanges.listen((List<Change<Vout>> batchedChanges) {
      // if vouts in our account has changed...
      //var items = batchedChanges
      //    .where((change) => change.record.address?.walletId == Current.walletId);
      /// new import process doesn't save addresses till end so we don't yet
      /// know the wallet of these items, so we have to make simpler heuristic
      final Iterable<Change<Vout>> items = batchedChanges.where(
          (Change<Vout> change) =>
              change.record.security?.symbol == widget.symbol);
      if (items.isNotEmpty) {
        print('refreshing list - vouts');
        setState(() {});
      }
    }));
    listeners.add(
        pros.rates.batchedChanges.listen((List<Change<Rate>> batchedChanges) {
      // ignore: todo
      // TODO: should probably include any assets that are in the holding of the main account too...
      final Iterable<Change<Rate>> changes = batchedChanges.where(
          (Change<Rate> change) =>
              change.record.base == pros.securities.RVN &&
              change.record.quote == pros.securities.USD);
      if (changes.isNotEmpty) {
        print('refreshing list - rates');
        setState(() {
          rateUSD = changes.first.record;
        });
      }
    }));
    widget.scrollController?.addListener(clampOnStart);
  }

  void clampOnStart() {
    if ((widget.scrollController?.position.pixels ?? 0) < 0)
      widget.scrollController?.jumpTo(0);
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    widget.scrollController?.removeListener(clampOnStart);
    super.dispose();
  }

  Future<void> refresh() async {
    setState(() {
      widget.cubit?.setTransactionViews(force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    transactions = widget.transactions ?? [];
    // ?? services.transaction.getTransactionViewSpoof(wallet: Current.wallet);
    if (transactions.isEmpty) {
      transactionCount = pros.unspents.bySymbol
          .getAll(widget.symbol ?? pros.securities.currentCoin.symbol)
          .length;
    } else {
      transactionCount = transactions.length;
    }
    return transactions.isEmpty && services.wallet.currentWallet.minerMode
        ? Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
                Container(
                    alignment: Alignment.topCenter,
                    padding:
                        const EdgeInsets.only(top: 32, left: 16, right: 16),
                    child: const Text(
                      '"Mine to Wallet" is enabled, so transaction history is not available. \n\nTo download your transaction history please disable "Mine to Wallet" in Settings.',
                      softWrap: true,
                      maxLines: 10,
                    )),
                if (services.developer.developerMode)
                  components.buttons.actionButtonSoft(
                    context,
                    label: 'Go to Settings',
                    link: '/settings/network/mining',
                  ),
                const SizedBox(height: 80),
              ])
        : RefreshIndicator(
            onRefresh: () => refresh(),
            child: transactions.isEmpty
                //? components.empty.transactions(context, msg: widget.msg)
                ? components.empty.getTransactionsPlaceholder(context,
                    scrollController: widget.scrollController!,
                    count:
                        transactionCount == 0 ? 1 : min(10, transactionCount))
                : Container(
                    alignment: Alignment.center,
                    child: _transactionsView(context),
                  ));
  }

  ListView _transactionsView(BuildContext context) => ListView(
      physics: const BouncingScrollPhysics(),
      //physics: (widget.scrollController?.position.pixels ?? 0) < 56
      //    ? ClampingScrollPhysics()
      //    : BouncingScrollPhysics(),
      controller: widget.scrollController,
      children: <Widget>[const SizedBox(height: 16)] +
          (services.wallet.leader.newLeaderProcessRunning
              ? <Widget>[
                  for (TransactionView _ in transactions) ...<Widget>[
                    components.empty.getTransactionsShimmer(context)
                  ]
                ]
              : <Widget>[
                  ...() {
                    var ret = [
                      for (TransactionView transactionView in transactions)
                        if ((pros.settings.hideFees &&
                                transactionView.type !=
                                    TransactionViewType.fee) ||
                            true) ...<Widget>[
                          ListTile(
                            //contentPadding:
                            //    EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 13),
                            onTap: () => Navigator.pushNamed(
                                context, '/transaction/transaction',
                                arguments: <String, TransactionView>{
                                  'transactionView': transactionView
                                }),
                            //onLongPress: _toggleUSD,
                            //leading: Container(
                            //    height: 40,
                            //    width: 40,
                            //    child: components.icons
                            //        .assetAvatar(transactionView.security.symbol)),
                            title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                      services.conversion.securityAsReadable(
                                          transactionView.iValueTotal,
                                          security: transactionView.security,
                                          asUSD: showUSD),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1),
                                  Text(
                                      '${transactionView.formattedDatetime} ${transactionView.type.specialPaddedDisplay(transactionView.feeOnly, transactionView.consolidationToSelf)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2!
                                          .copyWith(color: AppColors.black60)),
                                ]),
                            trailing: transactionView.feeOnly
                                ? components.icons.fee(context)
                                : (transactionView.sentToSelf &&
                                        !transactionView.isCoin
                                    ? components.icons.outIn(context)
                                    : (transactionView.outgoing
                                        ? components.icons.out(context)
                                        : components.icons.income(context))),
                          ),
                          const Divider(indent: 16),
                        ]
                    ];
                    ret = ret.sublist(
                        0,
                        transactions.length <= 15 ||
                                (widget.cubit?.state.end ?? true)
                            ? ret.length - 1
                            : ret.length);
                    return ret;
                  }()
                ]) +
          <Widget>[
            if (transactions.length > 15 &&
                !(widget.cubit?.state.end ?? true)) ...[
              components.empty.getTransactionsShimmer(context),
              const Divider(indent: 16),
            ],
            if (transactions.length <= 15 || (widget.cubit?.state.end ?? true))
              const Divider(
                indent: 0,
                endIndent: 0,
                color: AppColors.black12,
                thickness: 1.5,
              ),
            Container(
              height: 80 *
                  (transactions.length > 15 &&
                          (!(widget.cubit?.state.end ?? true))
                      ? 1.5
                      : 1),
              color: Colors.white,
            )
          ]);
}

/// Scroll physics for environments that prevent the scroll offset from reaching
/// beyond the bounds of the content.
///
/// This is the behavior typically seen on Android.
///
/// See also:
///
///  * [ScrollConfiguration], which uses this to provide the default
///    scroll behavior on Android.
///  * [BouncingScrollPhysics], which is the analogous physics for iOS' bouncing
///    behavior.
///  * [GlowingOverscrollIndicator], which is used by [ScrollConfiguration] to
///    provide the glowing effect that is usually found with this clamping effect
///    on Android. When using a [MaterialApp], the [GlowingOverscrollIndicator]'s
///    glow color is specified to use the overall theme's
///    [ColorScheme.secondary] color.
class ClampingBouncingScrollPhysics extends ScrollPhysics {
  /// Creates scroll physics that prevent the scroll offset from exceeding the
  /// bounds of the content.
  const ClampingBouncingScrollPhysics({super.parent});

  @override
  ClampingBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ClampingBouncingScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    assert(() {
      if (value == position.pixels) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              '$runtimeType.applyBoundaryConditions() was called redundantly.'),
          ErrorDescription(
            'The proposed new position, $value, is exactly equal to the current position of the '
            'given ${position.runtimeType}, ${position.pixels}.\n'
            'The applyBoundaryConditions method should only be called when the value is '
            'going to actually change the pixels, otherwise it is redundant.',
          ),
          DiagnosticsProperty<ScrollPhysics>(
              'The physics object in question was', this,
              style: DiagnosticsTreeStyle.errorProperty),
          DiagnosticsProperty<ScrollMetrics>(
              'The position object in question was', position,
              style: DiagnosticsTreeStyle.errorProperty),
        ]);
      }
      return true;
    }());
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      // Underscroll.
      return value - position.pixels;
    }
    //if (position.maxScrollExtent <= position.pixels &&
    //    position.pixels < value) {
    //  // Overscroll.
    //  return value - position.pixels;
    //}
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) {
      // Hit top edge.
      return value - position.minScrollExtent;
    }
    //if (position.pixels < position.maxScrollExtent &&
    //    position.maxScrollExtent < value) {
    //  // Hit bottom edge.
    //  return value - position.maxScrollExtent;
    //}
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (position.outOfRange) {
      double? end;
      if (position.pixels > position.maxScrollExtent) {
        end = position.maxScrollExtent;
      }
      if (position.pixels < position.minScrollExtent) {
        end = position.minScrollExtent;
      }
      assert(end != null);
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        end!,
        min(0.0, velocity),
        tolerance: tolerance,
      );
    }
    if (velocity.abs() < tolerance.velocity) {
      return null;
    }
    if (velocity > 0.0 && position.pixels >= position.maxScrollExtent) {
      return null;
    }
    if (velocity < 0.0 && position.pixels <= position.minScrollExtent) {
      return null;
    }
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      tolerance: tolerance,
    );
  }

  /// The multiple applied to overscroll to make it appear that scrolling past
  /// the edge of the scrollable contents is harder than scrolling the list.
  /// This is done by reducing the ratio of the scroll effect output vs the
  /// scroll gesture input.
  ///
  /// This factor starts at 0.52 and progressively becomes harder to overscroll
  /// as more of the area past the edge is dragged in (represented by an increasing
  /// `overscrollFraction` which starts at 0 when there is no overscroll).
  double frictionFactor(double overscrollFraction) =>
      0.52 * pow(1 - overscrollFraction, 2);

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    assert(offset != 0.0);
    assert(position.minScrollExtent <= position.maxScrollExtent);

    if (!position.outOfRange) {
      return offset;
    }

    final double overscrollPastEnd =
        max(position.pixels - position.maxScrollExtent, 0.0);
    final double overscrollPast = max(0.0, overscrollPastEnd);
    final bool easing = (overscrollPastEnd > 0.0 && offset > 0.0);

    final double friction = easing
        // Apply less resistance when easing the overscroll vs tensioning.
        ? frictionFactor(
            (overscrollPast - offset.abs()) / position.viewportDimension)
        : frictionFactor(overscrollPast / position.viewportDimension);
    final double direction = offset.sign;

    return direction * _applyFriction(overscrollPast, offset.abs(), friction);
  }

  static double _applyFriction(
      double extentOutside, double absDelta, double gamma) {
    assert(absDelta > 0);
    double total = 0.0;
    if (extentOutside > 0) {
      final double deltaToLimit = extentOutside / gamma;
      if (absDelta < deltaToLimit) {
        return absDelta * gamma;
      }
      total += extentOutside;
      absDelta -= deltaToLimit;
    }
    return total + absDelta;
  }

  // The ballistic simulation here decelerates more slowly than the one for
  // ClampingScrollPhysics so we require a more deliberate input gesture
  // to trigger a fling.
  @override
  double get minFlingVelocity => minFlingVelocity * 2.0;

  // Methodology:
  // 1- Use https://github.com/flutter/platform_tests/tree/master/scroll_overlay to test with
  //    Flutter and platform scroll views superimposed.
  // 3- If the scrollables stopped overlapping at any moment, adjust the desired
  //    output value of this function at that input speed.
  // 4- Feed new input/output set into a power curve fitter. Change function
  //    and repeat from 2.
  // 5- Repeat from 2 with medium and slow flings.
  /// Momentum build-up function that mimics iOS's scroll speed increase with repeated flings.
  ///
  /// The velocity of the last fling is not an important factor. Existing speed
  /// and (related) time since last fling are factors for the velocity transfer
  /// calculations.
  @override
  double carriedMomentum(double existingVelocity) {
    return existingVelocity.sign *
        min(0.000816 * pow(existingVelocity.abs(), 1.967).toDouble(), 40000.0);
  }

  // Eyeballed from observation to counter the effect of an unintended scroll
  // from the natural motion of lifting the finger after a scroll.
  @override
  double get dragStartDistanceMotionThreshold => 3.5;
}
