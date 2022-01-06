import 'package:flutter/material.dart';
import 'package:raven_front/backdrop/backdrop.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';

class BalanceHeader extends StatefulWidget {
  BalanceHeader({Key? key}) : super(key: key);

  @override
  _BalanceHeaderState createState() => _BalanceHeaderState();
}

class _BalanceHeaderState extends State<BalanceHeader> {
  List listeners = [];

  @override
  void initState() {
    super.initState();
    Backdrop.of(components.navigator.routeContext!).revealBackLayer();
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: ListView(
        shrinkWrap: true,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/rvnonly.png',
                height: 56,
                width: 56,
              ),
              SizedBox(height: 8),
              Text('amount', style: Theme.of(context).balanceAmount),
              SizedBox(height: 1),
              Text('dollars', style: Theme.of(context).balanceDollar),
              SizedBox(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Remaining:', style: Theme.of(context).remaining),
                Text('amount', style: Theme.of(context).remaining)
              ]),
            ],
          )
        ],
      ),
    );
  }
}
