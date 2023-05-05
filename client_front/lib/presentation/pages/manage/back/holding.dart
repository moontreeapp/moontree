import 'package:client_front/application/infrastructure/location/cubit.dart';
import 'package:client_front/application/manage/holding/cubit.dart';
import 'package:client_front/presentation/pages/wallet/front/holding.dart';
import 'package:client_front/presentation/widgets/back/coinspec/spec.dart';
import 'package:flutter/material.dart';
import 'package:client_front/presentation/services/services.dart' show screen;
import 'package:client_front/presentation/components/components.dart'
    as components;

class BackManageHoldingScreen extends StatelessWidget {
  final String chainSymbol;
  const BackManageHoldingScreen({Key? key, this.chainSymbol = ''})
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
    final ManageHoldingViewCubit cubit = components.cubits.manageHoldingView;
    final LocationCubit locCubit = components.cubits.location;
    final double minHeight = screen.frontContainer.midHeightPercentage * 1 +
        (48 / screen.frontContainer.maxHeight);
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
                security: locCubit.state.security,
                bottom: cubit.nullCacheView ? null : Container(),
              ),
            ),
          );
        });
  }
}
