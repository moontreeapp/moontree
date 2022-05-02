import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/services/wallet/constants.dart';

class BackdropAppBarContents extends StatelessWidget
    implements PreferredSizeWidget {
  final bool spoof;
  final bool animate;

  const BackdropAppBarContents(
      {Key? key, this.spoof = false, this.animate = true})
      : super(key: key);

  @override
  Size get preferredSize => const Size(double.infinity, 56);

  @override
  Widget build(BuildContext context) {
    final appBar = Platform.isIOS
        ? buildAppBar(
            context,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.black,
              statusBarIconBrightness: Brightness.light, // For Android
              statusBarBrightness: Brightness.dark, // For iOS
            ),
            backgroundColor: Colors.transparent,
            shape: components.shape.topRounded,
          )
        : buildAppBar(
            context,
            backgroundColor: Theme.of(context).backgroundColor,
            shape: components.shape.topRounded,
          );
    final alphaBar = Platform.isIOS
        ? Container(
            height: 56,
            child: ClipRect(
              child: Container(
                alignment: Alignment.topRight,
                child: Banner(
                  message: 'alpha',
                  location: BannerLocation.topEnd,
                  color: AppColors.success,
                ),
              ),
            ))
        : ClipRect(
            child: Container(
              alignment: Alignment.topRight,
              child: Banner(
                message: 'alpha',
                location: BannerLocation.topEnd,
                color: AppColors.success,
              ),
            ),
          );
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        if (Platform.isIOS)
          FrontCurve(
            height: 56,
            color: Theme.of(context).backgroundColor,
            fuzzyTop: false,
            frontLayerBoxShadow: const [],
          ),
        testAppBar(appBar, test: true),
        alphaBar,
        AppBarScrim(),
      ],
    );
  }

  Widget testAppBar(Widget appBar, {bool test = false}) => test
      ? GestureDetector(
          onTap: () async {
            print('click');
            //streams.app.snack.add(Snack(message: 'Sucessful Import'));
            //streams.app.scrim.add(!streams.app.scrim.value);
            streams.client.busy.add(!streams.client.busy.value);
            //print(res.wallets.data.length);
            //print(res.addresses.data.length);
            //print(res.wallets.data.first.holdingCount);
            //print(res.wallets.data.first.balances);
            //services.wallet.createSave(
            //    walletType: WalletType.leader,
            //    cipherUpdate: defaultCipherUpdate,
            //    secret: null);
            //print(await services.client.client!.getHistories(res.addresses.data
            //        .toList()
            //        .sublist(0, 2)
            //        .map((Address a) => a.scripthash))
            //return [
            //  for (var x in listOfLists) x.map((history) => history.txHash).toList()
            //];
            //    );
            print(
                'rvn ${await services.download.unspents.totalConfirmed(res.wallets.currentWallet.id, 'RVN')}');
            print(
                'rvn ${await services.download.unspents.totalUnconfirmed(res.wallets.currentWallet.id, 'RVN')}');
            print(() {
              var symbol = 'RVN';
              var possibleHoldings = [
                for (var balance in Current.holdings)
                  if (balance.security.symbol == symbol)
                    utils.satToAmount(balance.value)
              ];
              return possibleHoldings;
            }());
            print(Current.balanceRVN);
            print(Current.wallet.id);
          },
          child: appBar,
        )
      : appBar;

  Widget buildAppBar(
    BuildContext context, {
    SystemUiOverlayStyle? systemOverlayStyle,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) =>
      AppBar(
        systemOverlayStyle: systemOverlayStyle,
        backgroundColor: backgroundColor,
        shape: shape,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: streams.app.page.value == 'Login'
            ? null
            : PageLead(mainContext: context),
        centerTitle: spoof,
        title: PageTitle(animate: animate),
        actions: <Widget>[
          if (!spoof) components.status,
          if (!spoof) spoof ? SpoofedConnectionLight() : ConnectionLight(),
          if (!spoof) QRCodeContainer(),
          if (!spoof) SnackBarViewer(),
          if (!spoof) SizedBox(width: 6),
          if (!spoof) PeristentKeyboardWatcher(),
        ],
      );
}
