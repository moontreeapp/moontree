/// allow them to abort this process DONE
/// - and handle only being able to decrypt some wallets:
///   only matters when trying to backup wallets right?
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/services/password.dart';
import 'package:client_front/services/storage.dart' show SecureStorage;
import 'package:client_front/utils/auth.dart';

class ChangeResume extends StatefulWidget {
  @override
  _ChangeResumeState createState() => _ChangeResumeState();
}

class _ChangeResumeState extends State<ChangeResume> {
  TextEditingController password = TextEditingController();
  bool passwordVisible = false;

  @override
  void initState() {
    passwordVisible = false;
    super.initState();
  }

  @override
  void dispose() {
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          //appBar: components.headers.simple(context, 'Password Recovery'),
          body: body(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: submitButton(),
        ));
  }

  Row submitButton() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        TextButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(
                context, getMethodPathLogin(), arguments: <dynamic, dynamic>{}),
            icon: const Icon(Icons.login),
            label: Text('Abort Password Change Process',
                style: TextStyle(color: Theme.of(context).primaryColor))),
        TextButton.icon(
            onPressed: () async => submit(),
            icon: const Icon(Icons.login),
            label: Text('Login',
                style: TextStyle(color: Theme.of(context).primaryColor))),
      ]);

  Column body() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                  autocorrect: false,
                  controller: password,
                  obscureText: !passwordVisible,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    hintText: 'previous password',
                    suffixIcon: IconButton(
                      icon: Icon(
                          passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark),
                      onPressed: () => setState(() {
                        passwordVisible = !passwordVisible;
                      }),
                    ),
                  ),
                  onEditingComplete: () => submit())),
        ],
      );

  Future<void> submit() async {
    final String key = await SecureStorage.authenticationKey;
    if (services.password.validate.previousPassword(
      password: key,
      salt: key,
      saltedHashedPassword: await getPreviousSaltedHashedPassword(),
    )) {
      FocusScope.of(context).unfocus();
      services.cipher.initCiphers(
        altPassword: key,
        altSalt: key,
        currentCipherUpdates: services.wallet.getPreviousCipherUpdates,
      );
      await successMessage();
    } else if (services.password.validate.previousPassword(
      password: password.text,
      salt: key,
      saltedHashedPassword: await getPreviousSaltedHashedPassword(),
    )) {
      FocusScope.of(context).unfocus();
      services.cipher.initCiphers(
        altPassword: password.text,
        altSalt: key,
        currentCipherUpdates: services.wallet.getPreviousCipherUpdates,
      );
      successMessage();
    } else if (services.password.validate.previousPassword(
      password: password.text,
      salt: key,
      saltedHashedPassword: await getPreviousSaltedHashedPassword(),
    )) {
      FocusScope.of(context).unfocus();
      services.cipher.initCiphers(
        altPassword: password.text,
        altSalt: key,
        currentCipherUpdates: services.wallet.getPreviousCipherUpdates,
      );
      successMessage();
    } else {
      final String oldSalt = pros.passwords.primaryIndex.getPrevious()!.salt;
      if (services.password.validate.previousPassword(
        password: password.text,
        salt: oldSalt,
        saltedHashedPassword:
            pros.passwords.primaryIndex.getPrevious()!.saltedHash,
      )) {
        FocusScope.of(context).unfocus();
        services.cipher.initCiphers(
          altPassword: password.text,
          altSalt: oldSalt,
          currentCipherUpdates: services.wallet.getPreviousCipherUpdates,
        );
        successMessage();
      } else {
        final int? used =
            services.password.validate.previouslyUsed(password.text);
        failureMessage(used == null
            ? 'This password was not recognized to match any previously used passwords.'
            : 'The provided password was used $used passwords ago.');
      }
      setState(() {});
    }
  }

  Future<void> failureMessage(String msg) => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
              title: const Text('Change Password Recovery failure'),
              content: Text('Previous password did not match. $msg'),
              actions: <Widget>[
                TextButton(
                    child: const Text('ok'),
                    onPressed: () => Navigator.pop(context))
              ]));

  Future<void> successMessage() => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
              title: const Text('Success!'),
              content: const Text(
                  'Previous password matched. Change password recovery '
                  'process will continue, please enter your current '
                  'password.'),
              actions: <Widget>[
                TextButton(
                    child: const Text('ok'),
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, getMethodPathLogin(),
                        arguments: <dynamic, dynamic>{}))
              ]));
}
