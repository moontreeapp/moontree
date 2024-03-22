import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubits.dart';

class TransactionsFeedPage extends StatelessWidget {
  final ScrollController scroller;
  const TransactionsFeedPage({super.key, required this.scroller});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TransactionsFeedCubit, TransactionsFeedState>(
          builder: (BuildContext context, TransactionsFeedState state) =>
              ListView.builder(
                  controller: scroller,
                  shrinkWrap: true,
                  itemCount: 100,
                  itemBuilder: (context, index) => ListTile(
                        onTap: () => print('tapped'),
                        title: Text('tx $index',
                            style: const TextStyle(color: Colors.grey)),
                      )));
}
