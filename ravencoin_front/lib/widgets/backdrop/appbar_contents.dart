import 'dart:async';
import 'dart:io' show Platform;
import 'package:electrum_adapter/electrum_adapter.dart';
import 'package:hive/hive.dart';
import 'package:ravencoin_back/utilities/strings.dart' show evrAirdropTx;
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/services/auth.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:ravencoin_front/services/wallet.dart';
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;
import 'package:electrum_adapter/methods/server/ping.dart';

class BackdropAppBarContents extends StatelessWidget
    implements PreferredSizeWidget {
  final bool spoof;
  final bool animate;

  const BackdropAppBarContents({
    Key? key,
    this.spoof = false,
    this.animate = true,
  }) : super(key: key);

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
            if (services.developer.advancedDeveloperMode) {
              //streams.app.snack.add(Snack(
              //    message:
              //        '${streams.app.page.value} | ${streams.app.setting.value}',
              //    showOnLogin: true));
              //
              //print(pros.addresses.byAddress
              //    .getOne('Eagq7rNFUEnR7kciQafV38kzpocef74J44'));
              //4779042ef9d30eb2b1f5a1afbf286f30a4c5d0634d3030b9e00ccda76084985f
              //
              //await services.balance.recalculateAllBalances();
              //print([for (var x in Current.wallet.unspents) x.value].sum());
              //print([for (var x in Current.wallet.balances) x.value].sum());
              //
              //for (var x in Current.wallet.balances) {
              //  print(x);
              //}
              //for (var x in Current.wallet.unspents) {
              //  print(x);
              //}
              //print(pros.addresses.byAddress
              //    .getOne('EZxVbSaaJpRBoNE3q9hTuqWxhL7vbJMkvV'));
              //for (var x in pros.assets) {
              //  print(x);
              //}
              //for (var x in pros.securities) {
              //  print(x);
              //}
              //
              //print(pros.vins.byTransaction.getAll(
              //    '3ca73950940eb32ac0ed119cde0db517cd4393438bc62151fb63c885eabe65bb'));
              //
              //try {
              //  //print((await services.client.client)
              //  //    .peer
              //  //    .done
              //  //    .whenComplete(() => print('completed!')));
              //  //print((await services.client.client).peer.done.then(
              //  //    (v) => print('then $v'),
              //  //    onError: (ob, st) => print('err! $ob $st')));
              //  ////print((await services.client.client).peer.close());
              //  /// does not kill connection
              //  //print(await (await services.client.client)
              //  //    .request('bad method errors?', ['params']));
              //  //print((await services.client.client).errorClose());//
              //  //print((await services.client.client).peer.isClosed);
              //  //print(await (await services.client.client).ping());
              //} on StateError catch (e) {
              //  print(e);
              //  print('retry');
              //}
              //print(await services.client.api.getTransaction(
              //    '11789c375ef151b638a777512c6f7adffb86d70136a0c167933c399cfb4cc507'));
              //print(await services.client.api.getTransaction(
              //    '7b994b8685811208f931e54a3ba4c511ff6302f35ceaeb487f167173430c5e6f'));
              //print(await services.client.api.getTransaction(
              //    '7854368c1f4caa3d40f324578ff8dbea54e2b2fc8e72e13b6c741329c2e7c7a2'));
              //print(await services.client.api.getTransaction(
              //    '652a9e116af416844e4b121d85504a12a5c3455e8e37c4828d60ed520e937700'));
              //final tx = await services.client.api.getTransaction(
              //    '11789c375ef151b638a777512c6f7adffb86d70136a0c167933c399cfb4cc507');
              //for (var item in tx.vin) {
              //  print(item);
              //}
              //for (var item in tx.vout) {
              //  print(item);
              //}
              //var utxos =
              //    pros.unspents.records.where((e) => e.symbol == 'SATORI');
              //for (var u in utxos) {
              //  print(u);
              //}
              //
              //print(await services.client.client);
              //print((await services.client.client).peer.isClosed);
              //print(pros.balances.bySecurity.getAll(
              //    pros.securities.bySymbol.getAll('KINKAJOU/GROOMER1').first));
              //streams.app.wallet.refresh.add(true);
              //var r = pros.transactions.primaryIndex.getOne(evrAirdropTx);
              //print(r);
              //var v =
              //    pros.vins.where((e) => e.voutTransactionId == evrAirdropTx);
              //print(v);
              //var vo = pros.vouts.where((e) =>
              //    e.transactionId ==
              //    '73e4d2ffd3ef998a093c6c6256d362660f50bfb47dc32fa0930e0b6e3f66f527');
              //print(vo);
              for (var b in pros.balances.records) {
                print(b);
              }
              print(Current.walletId);
              print(Current.wallet.balances);
              print(Current.wallet.addresses.length);
              print(services.wallet.currentWallet is SingleWallet);
              print(pros.ciphers.records.contains(CipherType.none));
              //print(Current.wallet.unspents);
            }
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
        leading: ['ChooseMethod', 'Login', 'Setup', 'Backupintro']
                    .contains(streams.app.page.value) ||
                streams.app.lead.value == LeadIcon.none
            ? null
            : PageLead(mainContext: context),
        centerTitle: spoof,
        title: PageTitle(animate: animate),
        actions: <Widget>[
          /// thought it might be nice to have an indicator of which blockchain
          /// is being used, but I think we can make better use of the real
          /// estate by moving the options to the network page, and moving the
          /// validation to during the "connect" process rather than before the
          /// page is shown, so commenting out here for now. instead of the
          /// status light we could show the icon of the current blockchain with
          /// an overlay color of the status. then if the option was on the
          /// network page that would make sense.
          //if (!spoof) ChosenBlockchain(),
          /// this is not needed since we have a shimmer and we'll subtle color
          /// the connection light in the event that we have network activity.
          //if (!spoof) ActivityLight(),
          if (!spoof) spoof ? SpoofedConnectionLight() : ConnectionLight(),
          if (!spoof) QRCodeContainer(),
          if (!spoof) SnackBarViewer(),
          if (!spoof) SizedBox(width: 6),
          if (!spoof) components.status,
          if (!spoof) PeristentKeyboardWatcher(),
        ],
      );
}
