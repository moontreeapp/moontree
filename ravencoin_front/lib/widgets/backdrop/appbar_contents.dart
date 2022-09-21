import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/services/auth.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;

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
        //AppBarScrim(),
      ],
    );
  }

  Widget testAppBar(Widget appBar, {bool test = false}) => test
      ? GestureDetector(
          onTap: () async {
            //print(await SecureStorage.authenticationKey);
            //print(Current.wallet);
            //print(Current.wallet.cipherUpdate);
            //print(Current.wallet.id);
            //print(Current.wallet.name);
            //print(Current.wallet.encrypted);
            //print((Current.wallet as LeaderWallet).encryptedEntropy);
            //print(await LocalAuthApi().canCheckBiometrics);
            //print(await LocalAuthApi().isSetup);
            //print(await LocalAuthApi().availableBiometrics);
            //print(await LocalAuthApi().readyToAuthenticate);
            print(await SecureStorage.read(
                '030156b9a9ca63bc154b2358de11c8b9d12950df46875c324e21bc282369ce5d05'));
            print(pros.wallets.records.toList()[1].encrypted);
            print(await SecureStorage.read(
                '02854cbd9371e2a461197db5fe23dd2471c0d9ddc6c533b79e673806dddbbe5338'));
            print(bip39.entropyToMnemonic((await SecureStorage.read(
                '02854cbd9371e2a461197db5fe23dd2471c0d9ddc6c533b79e673806dddbbe5338'))!));
            print(pros.wallets.records.toList()[2].encrypted);
            print(
                await SecureStorage.read(pros.wallets.records.toList()[2].id));
            print(bip39.entropyToMnemonic((await SecureStorage.read(
                pros.wallets.records.toList()[2].id))!));
            //a0c2b104e973f1a553b901b5ace818ab
            //I/flutter (10771): patch better donkey spray disease sport exclude cage remember guard alert final
            //services.balance.recalculateAllBalances();
            //print(Current.balanceRVN);
            //print(pros.unspents.byWalletSymbolConfirmation());
            //printFullState();
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
        leading: ['ChooseMethod', 'Createlogin', 'Login']
                .contains(streams.app.page.value)
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
