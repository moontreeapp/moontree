import 'package:flutter/material.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/services/services.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) => ListView.builder(
      controller: cubits.pane.state.scroller!,
      shrinkWrap: true,
      itemCount: 100,
      itemBuilder: (context, index) => ListTile(
            onTap: maestro.activateTransactions,
            title:
                Text('Item $index', style: const TextStyle(color: Colors.grey)),
          ));
}
