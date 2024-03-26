import 'package:flutter/material.dart';
import 'package:moontree/cubits/cubit.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) => ListView.builder(
      controller: cubits.pane.state.scroller,
      shrinkWrap: true,
      itemCount: 25,
      itemBuilder: (context, index) => ListTile(
            onTap: () => print('tapped'),
            title:
                Text('tx $index', style: const TextStyle(color: Colors.grey)),
          ));
}
