import 'dart:async';
import 'package:flutter/material.dart';
import 'package:magic/services/auth.dart';

class LoginNative extends StatefulWidget {
  const LoginNative({super.key});

  @override
  LoginNativeState createState() => LoginNativeState();
}

class LoginNativeState extends State<LoginNative> {
  bool autoInitiateUnlock = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (autoInitiateUnlock!) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await submit();
      });
      autoInitiateUnlock = false;
    }
    return const SizedBox.shrink();
  }

  Future<void> submit() async {
    final LocalAuthApi localAuthApi = LocalAuthApi();
    final bool validate = await localAuthApi.authenticate(skip: false);
    if (validate) {
      // tell cubit
      if (mounted) {
        setState(() {});
      }
    }
  }
}
