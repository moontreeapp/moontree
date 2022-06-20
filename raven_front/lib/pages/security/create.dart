import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/utils/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateLogin extends StatefulWidget {
  @override
  _CreateLoginState createState() => _CreateLoginState();
}

class _CreateLoginState extends State<CreateLogin> {
  late List listeners = [];
  var password = TextEditingController();
  var confirm = TextEditingController();
  var passwordVisible = false;
  var confirmVisible = false;
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmFocus = FocusNode();
  FocusNode unlockFocus = FocusNode();
  bool noPassword = true;
  String? passwordText;
  final int minimumLength = 1;

  Future<void> exitProcess() async {
    await setupWallets();
    Navigator.pushReplacementNamed(context, '/home', arguments: {});
    services.cipher.initCiphers(altPassword: passwordText);
    await services.cipher.updateWallets();
    services.cipher.cleanupCiphers();
    services.cipher.loginTime();
    streams.app.splash.add(false); // trigger to refresh app bar again
    streams.app.logout.add(false);
  }

  @override
  void initState() {
    super.initState();
    listeners.add(streams.password.exists.listen((bool value) {
      if (value && noPassword) {
        noPassword = false;
        exitProcess();
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    password.dispose();
    confirm.dispose();
    passwordFocus.dispose();
    confirmFocus.dispose();
    unlockFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropLayers(back: BlankBack(), front: FrontCurve(child: body()));
  }

  Widget body() => GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: CustomScrollView(slivers: <Widget>[
            SliverToBoxAdapter(
              child: Container(
                  alignment: Alignment.bottomCenter,
                  height: .242.ofMediaHeight(context),
                  child: moontree),
            ),
            SliverToBoxAdapter(
                child: SizedBox(height: .01.ofMediaHeight(context))),
            SliverToBoxAdapter(
              child: Container(
                  alignment: Alignment.bottomCenter,
                  height: .035.ofMediaHeight(context),
                  child: welcomeMessage),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: .0789.ofMediaHeight(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                  alignment: Alignment.topCenter,
                  // height: 76,
                  height: .0947.ofMediaHeight(context),
                  child: passwordField),
            ),
            SliverToBoxAdapter(
              child: Container(
                  alignment: Alignment.topCenter,
                  // height: 76 + 16,
                  height: .0947.ofMediaHeight(context),
                  child: confirmField),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            SliverToBoxAdapter(
              child: Container(
                alignment: Alignment.topCenter,
                child: components.text.passwordWarning,
              ),
            ),
            SliverFillRemaining(
                hasScrollBody: false,
                child: KeyboardHidesWidgetWithDelay(
                    fade: true,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: .063.ofMediaHeight(context),
                          ),
                          ulaMessage,
                          SizedBox(
                            height: .021.ofMediaHeight(context),
                          ),
                          Row(children: [unlockButton]),
                          SizedBox(
                            height: .052.ofMediaHeight(context),
                          ),
                        ]))),
          ])));

  Widget get moontree => Container(
        child: SvgPicture.asset('assets/logo/moontree_logo.svg'),
        height: .1534.ofMediaHeight(context),
        // height: 110.figma(context),
      );

  Widget get welcomeMessage => Text('Moontree',
      style: Theme.of(context)
          .textTheme
          .headline1
          ?.copyWith(color: AppColors.black60));

  Widget get ulaMessage => RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style:
              Theme.of(components.navigator.routeContext!).textTheme.bodyText2,
          children: <TextSpan>[
            TextSpan(text: 'By tapping Create Wallet,\nyou agree to our '),
            TextSpan(
                text: 'User Agreement',
                style:
                    Theme.of(components.navigator.routeContext!).textTheme.link,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(Uri.parse('https://moontree.com/ula'));
                  }),
          ],
        ),
      );

  Widget get passwordField => TextFieldFormatted(
      focusNode: passwordFocus,
      autocorrect: false,
      controller: password,
      obscureText: !passwordVisible,
      textInputAction: TextInputAction.next,
      labelText: 'Password',
      errorText: password.text != '' && password.text.length < minimumLength
          ? 'password must be at least $minimumLength characters long'
          : null,
      helperText: !(password.text != '' && password.text.length < minimumLength)
          ? ''
          : null,
      suffixIcon: IconButton(
        icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.black60),
        onPressed: () => setState(() {
          passwordVisible = !passwordVisible;
        }),
      ),
      onEditingComplete: () {
        if (password.text != '' && password.text.length >= minimumLength) {
          FocusScope.of(context).requestFocus(confirmFocus);
        }
        setState(() {});
      });

  Widget get confirmField => TextFieldFormatted(
      focusNode: confirmFocus,
      autocorrect: false,
      controller: confirm,
      obscureText: !confirmVisible, // masked controller for immediate?
      textInputAction: TextInputAction.done,
      labelText: 'Confirm Password',
      errorText: confirm.text != '' && confirm.text != password.text
          ? 'does not match password'
          : null,
      helperText: confirm.text == password.text ? 'match' : null,
      suffixIcon: IconButton(
        icon: Icon(confirmVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.black60),
        onPressed: () => setState(() {
          confirmVisible = !confirmVisible;
        }),
      ),
      onEditingComplete: () {
        if (confirm.text == password.text) {
          FocusScope.of(context).requestFocus(unlockFocus);
        }
        setState(() {});
      });

  Widget get unlockButton => components.buttons.actionButton(context,
      enabled: validate() && passwordText == null,
      focusNode: unlockFocus,
      label: passwordText == null ? 'Create Wallet' : 'Creating Wallet...',
      disabledOnPressed: () => setState(() {}),
      onPressed: () async => await submit());

  bool validate() {
    return password.text != '' &&
        password.text.length >= minimumLength &&
        confirm.text == password.text;
  }

  Future submit({bool showFailureMessage = true}) async {
    await Future.delayed(Duration(milliseconds: 200)); // in release mode?
    if (validate() && passwordText == null) {
      // only run once
      setState(() {}); // to disable the button visually
      passwordText = password.text;
      streams.password.update.add(password.text);
      streams.app.verify.add(true);
    } else {
      setState(() {
        password.text = '';
      });
    }
  }

  Future setupRealWallet(String? id) async {
    await dotenv.load(fileName: '.env');
    var mnemonic = id == null ? null : dotenv.env['TEST_WALLET_0$id']!;
    await services.wallet.createSave(
        walletType: WalletType.leader,
        cipherUpdate: services.cipher.currentCipherUpdate,
        secret: mnemonic);
  }

  Future setupWallets() async {
    //if (res.addresses.data.isNotEmpty) {
    //  services.wallet.leader.updateIndexes();
    //}

    if (res.wallets.data.isEmpty) {
      //await setupRealWallet('1');
      //await setupRealWallet('2');
      //services.password.create.save('a');
      await setupRealWallet(null);
      await res.settings.setCurrentWalletId(res.wallets.first.id);
      await res.settings.savePreferredWalletId(res.wallets.first.id);
    }

    // for testing
    //print('-------------------------');
    //print('addresses: ${res.addresses.length}');
    //print('assets: ${res.assets.length}');
    //print('balances: ${res.balances.length}');
    //print('blocks: ${res.blocks}');
    //print('ciphers: ${res.ciphers}');
    //print('metadata: ${res.metadatas.length}');
    //print('passwords: ${res.passwords}');
    //print('rates: ${res.rates}');
    //print('securities: ${res.securities.length}');
    //print('settings: ${res.settings.length}');
    //print('transactions: ${res.transactions.length}');
    //print('vins: ${res.vins.length}');
    //print('vouts: ${res.vouts.length}');
    //print('wallets: ${res.wallets}');
    //print('-------------------------');
    ////print(services.cipher.getPassword(altPassword: ''));
    //print('-------------------------');
  }
}
