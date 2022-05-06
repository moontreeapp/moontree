import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/utils/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';

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
                  //color: Colors.red,
                  height: 180.figma(context),
                  child: moontree),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: Container(
                  alignment: Alignment.bottomCenter,
                  //color: Colors.green,
                  height: 33,
                  child: welcomeMessage),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 50)),
            SliverToBoxAdapter(
              child: Container(
                  alignment: Alignment.topCenter,
                  height: 76 + 16,
                  child: passwordField),
            ),
            SliverToBoxAdapter(
              child: Container(
                  alignment: Alignment.topCenter,
                  height: 76 + 16,
                  child: confirmField),
            ),
            SliverFillRemaining(
                hasScrollBody: false,
                child: KeyboardHidesWidgetWithDelay(
                    fade: true,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 50),
                          warning,
                          SizedBox(height: 50),
                          Row(children: [unlockButton]),
                          SizedBox(height: 40),
                        ]))),
          ])));

  Widget get moontree => Image(image: AssetImage('assets/logo/moontree.png'));

  Widget get welcomeMessage => Text(
        'Create Password',
        style: Theme.of(context).textTheme.headline1,
      );

  Widget get passwordField => TextField(
      focusNode: passwordFocus,
      autocorrect: false,
      controller: password,
      obscureText: !passwordVisible,
      textInputAction: TextInputAction.done,
      decoration: components.styles.decorations.textField(
        context,
        focusNode: passwordFocus,
        labelText: 'Password',
        errorText: password.text != '' && password.text.length < 4
            ? 'password must be at least 4 characters long'
            : null,
        helperText:
            !(password.text != '' && password.text.length < 4) ? '' : null,
        suffixIcon: IconButton(
          icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: AppColors.black60),
          onPressed: () => setState(() {
            passwordVisible = !passwordVisible;
          }),
        ),
      ),
      onEditingComplete: () {
        if (password.text != '' && password.text.length >= 4) {
          FocusScope.of(context).requestFocus(confirmFocus);
        }
        setState(() {});
      });

  Widget get confirmField => TextField(
      focusNode: confirmFocus,
      autocorrect: false,
      controller: confirm,
      obscureText: !confirmVisible, // masked controller for immediate?
      textInputAction: TextInputAction.done,
      decoration: components.styles.decorations.textField(
        context,
        focusNode: confirmFocus,
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
      ),
      onEditingComplete: () {
        if (confirm.text == password.text) {
          FocusScope.of(context).requestFocus(unlockFocus);
        }
        setState(() {});
      });

  Widget get warning => Text(
        'Your password cannot be recoverd.\nDo not forget your password.',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: AppColors.error),
      );

  Widget get unlockButton => components.buttons.actionButton(context,
      enabled: validate(),
      focusNode: unlockFocus,
      label: 'Set Password',
      disabledOnPressed: () => setState(() {}),
      onPressed: () async => await submit());

  bool validate() {
    return password.text != '' &&
        password.text.length >= 4 &&
        confirm.text == password.text;
  }

  Future submit({bool showFailureMessage = true}) async {
    await Future.delayed(Duration(milliseconds: 200));
    if (validate() && passwordText == null) {
      // only run once
      passwordText = password.text;
      streams.password.update.add(password.text);
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
