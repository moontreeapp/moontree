import 'package:flutter/material.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/services/services.dart' show sailor;

class FrontCreateNativeScreen extends StatelessWidget {
  const FrontCreateNativeScreen({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('frontLoginCreateNative');

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              padding: const EdgeInsets.only(left: 16),
              height: 56,
              width: 100,
              child: components.buttons.actionButton(
                context,
                enabled: true,
                label: 'NATIVE',
                onPressed: () async {
                  sailor.sailTo(location: '/login/native');
                  //Navigator.pushReplacementNamed(
                  //    context, getMethodPathCreate(),
                  //    arguments: <String, bool>{
                  //      'needsConsent': true
                  //    });
                },
              )),
        ],
      ),
    );
  }
}
