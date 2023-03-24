import 'package:client_back/records/security.dart';
import 'package:client_back/server/src/protocol/comm_balance_view.dart';
import 'package:client_front/application/transactions/cubit.dart';
import 'package:client_front/presentation/pages/wallet/front_holding.dart';
import 'package:client_front/presentation/widgets/back/coinspec/spec.dart';
import 'package:flutter/material.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/utils/ext.dart';
import 'package:client_front/presentation/services/services.dart' show screen;
import 'package:client_front/presentation/components/components.dart'
    as components;

class BackHoldingScreen extends StatelessWidget {
  final String chainSymbol;
  const BackHoldingScreen({Key? key, this.chainSymbol = ''})
      : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('backHolding');

  @override
  Widget build(BuildContext context) => Container(
        height: screen.frontContainer.inverseMid,
        //color: Colors.transparent,
        alignment: Alignment.center,
        child: CoinDetailsHeader(),
        //Container(
        //  transform: Matrix4.identity()..translate(0.0, -28.0, 0.0),
        //  height: 56,
        //  width: 56,
        //  child: CircleAvatar(
        //    backgroundColor: AppColors.primary,
        //    minRadius: 40,
        //    child: Text(chainSymbol.characters.firstOrNull ?? '?'),
        //  ),
        //),
      );
}

class CoinDetailsHeader extends StatelessWidget {
  const CoinDetailsHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TransactionsViewCubit cubit = components.cubits.transactionsView;
    final double minHeight = screen.frontContainer.midHeightPercentage;
    return StreamBuilder<double>(
        stream: cubit.state.scrollObserver,
        builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
          return Transform.translate(
            offset: Offset(
                0,
                0 -
                    (((snapshot.data ?? minHeight) as double) - minHeight) *
                        100),
            child: Opacity(
              //angle: ((snapshot.data ?? 0.9) as double) * pi * 180,
              opacity: getOpacityFromController(
                (snapshot.data ?? .9) as double,
                minHeight,
              ),
              child: CoinSpec(
                pageTitle: 'Transactions',
                security: cubit.state.security,
                bottom: cubit.nullCacheView ? null : Container(),
              ),
            ),
          );
        });
  }
}
