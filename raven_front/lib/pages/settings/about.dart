import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';

class About extends StatefulWidget {
  @override
  State createState() => new _AboutState();
}

//class About extends StatelessWidget {
class _AboutState extends State<About> {
  String img = 'assets/rvnonly.png';
  String explain =
      'RVN Bag is a non-custodial, lightweight, mobile wallet for Ravencoin.\n\n';
  String verbose =
      ('RVN Bag is a non-custodial (your keys are on your device), lightweight (no need to download the whole blockchain), mobile wallet for Ravencoin.\n\n'
      //'With RVN Bag you can:\n'
      //'  • import and backup wallets at any level of granularity,\n'
      //'  • manage multiple isolated accounts,\n'
      //'  • send and receive RVN,\n'
      //'  • send and receive any RVN asset,\n'
      //'  • create, issue, and reissue all kinds of RVN assets,\n'
      //'  • manage resticted, sub, qualifier, and uinque assets,\n'
      //'  • open messaging channels and communicate with stake holders,\n'
      //'  • and trade RVN and assets on the decentalized peer-to-peer exchange.\n\n'
      );
  String? about;

  @override
  Widget build(BuildContext context) {
    about = about ?? explain;
    return Scaffold(
        //appBar: components.headers.back(context, 'About'),
        body: Center(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () => setState(() => img = img == 'assets/splash/fast.gif'
                  ? 'assets/rvnonly.png'
                  : 'assets/splash/fast.gif'),
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Image.asset(img
                      //'assets/splash/fast.gif',
                      //'assets/rvn.png',
                      //fit: BoxFit.cover, // this is the solution for border
                      //width: 110.0,
                      //height: 110.0,
                      )),
            ),
            Text('Github.com/moontreeapp'),
            Text('MoonTree LLC, 2021'),
            SizedBox(height: 50),
            GestureDetector(
              onTap: () =>
                  setState(() => about = about == explain ? verbose : explain),
              child: Padding(padding: EdgeInsets.all(20), child: Text(about!)),
            ),
          ],
        ),
      ),
    ));
  }
}
