import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_front/components/components.dart';

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
              statusBarBrightness: Brightness.dark, // For iOS
            ),
            backgroundColor: Colors.transparent,
            shape: components.shape.topRounded8,
          )
        : buildAppBar(
            context,
            backgroundColor: AppColors.primary,
            shape: components.shape.topRounded8,
          );
    /*final alphaBar = Platform.isIOS
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
          );*/
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
        // alphaBar,
        AppBarScrim(),
      ],
    );
  }

  Widget testAppBar(Widget appBar, {bool test = false}) => test
      ? GestureDetector(
          onTap: () async {
            //streams.app.snack.add(Snack(message: 'hi'));
            //print(services.wallet.leader.newLeaderProcessRunning);
            //print(res.unspents.byWallet.getAll(res.wallets.first.id).length);
            //print(res.wallets.first.addresses.length);
            //print(res.addresses.byAddress
            //    .getOne('mjqUCAqLqnREGDpwtWX4daDNAynAJ86wsW'));
            //print(res.wallets.primaryIndex
            //    .getOne(
            //        '03e72076c1d3ab00146746c42950124846013de01d219f8d5ac99ef1a3226a11f2')!
            //    .addresses
            //    .length);
            print(Current.walletId);
            //03e72076c1d3ab00146746c42950124846013de01d219f8d5ac99ef1a3226a11f2
            //print(res.unspents.byWalletSymbol.getAll(
            //    '03e72076c1d3ab00146746c42950124846013de01d219f8d5ac99ef1a3226a11f2',
            //    'MOONTREETESTASSET/TESTSUB!'));
            ////res.transactions.chronological.forEach((e) => print(e));
            //print(res.transactions.primaryIndex.getOne(
            //    'c667cae71a6afbf9b7456fe9be33640ba2412e8eed304fc9b98e76e69bc297e7'));
            //Current.wallet.addresses.forEach((element) {
            //  print(element.address);
            //});
            //'mhDX42MrwMrPGskBP6q7CoyaWFuAgGx8Rm'
            var givenAddresses = {'mhDX42MrwMrPGskBP6q7CoyaWFuAgGx8Rm'};
            //    .map((address) => address.address)
            //    .toSet();
            //print(res.transactions.primaryIndex.getOne(
            //print(res.vouts.length);
            //    '72de633692442c9f01c0511a0becd547365fb4302b240bb79be9a09e94a1862c'));
            // not downloading the tx or vouts
            ///print(res.addresses.byAddress
            ///    .getOne('mhDX42MrwMrPGskBP6q7CoyaWFuAgGx8Rm'));
            ///print(services.client.subscribe.subscriptionHandlesAddress.containsKey(
            ///    'a2d2e0f63707574434fb64777e870c23d7c66c074930f65812eed092edd542e3'));
            ///
            ///print(res.addresses.byAddress
            ///    .getOne('mxNvrZVPBgU4H2piP5bag2vrjZ6K8pd3Ze'));
            ///
            //print(res.transactions.primaryIndex.getOne(
            //print(res.vouts.byTransaction.getAll(
            //    'fc7fdbbc3d189f23e1378ada1ba3bebae023b036cc6f5405e593745283d8da37'));
            //24d9aece25bfb453f5e540e1017983c5d1542e02195aecccfe8e66d713e07a52
            //for (var transaction in res.transactions.chronological) {
            //  var securitiesInvolved = ((transaction.vins
            //              .where((vin) =>
            //                  givenAddresses.contains(vin.vout?.toAddress) &&
            //                  vin.vout?.security != null)
            //              .map((vin) => vin.vout?.security)
            //              .toList()) +
            //          (transaction.vouts
            //              .where((vout) =>
            //                  givenAddresses.contains(vout.toAddress) &&
            //                  vout.security != null)
            //              .map((vout) => vout.security)
            //              .toList()))
            //      .toSet();
            //  print(transaction);
            //  print(securitiesInvolved);
            //}
            //services.client.subscribe.subscriptionHandlesAddress
            //    .forEach((key, value) {
            //  print(res.addresses.primaryIndex.getOne(key));
            //});
            print(services.client.subscribe.subscriptionHandlesAddress[
                '3ea41766ce551457e99c8a3eb3eb28240368331858f1d5706c880c0af2607072']);
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
        leading: ['Login', 'Createlogin'].contains(streams.app.page.value)
            ? null
            : PageLead(mainContext: context),
        centerTitle: spoof,
        title: PageTitle(animate: animate),
        actions: <Widget>[
          if (!spoof) ActivityLight(),
          if (!spoof) spoof ? SpoofedConnectionLight() : ConnectionLight(),
          if (!spoof) QRCodeContainer(),
          if (!spoof) SnackBarViewer(),
          if (!spoof) SizedBox(width: 6),
          if (!spoof) components.status,
          if (!spoof) PeristentKeyboardWatcher(),
        ],
      );
}
