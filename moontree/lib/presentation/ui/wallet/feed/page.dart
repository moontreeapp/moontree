import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/cubits/cubits.dart';
import 'package:moontree/presentation/ui/wallet/transactions/feed/page.dart';
import 'package:moontree/presentation/utils/animation.dart';
import 'package:moontree/services/services.dart';

class WalletFeedPage extends StatelessWidget {
  const WalletFeedPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<WalletFeedCubit, WalletFeedState>(
          builder: (BuildContext context, WalletFeedState state) =>
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: 100,
                  itemBuilder: (context, index) => ListTile(
                        onTap: maestro.activateTransactions,
                        title: Text('Item $index',
                            style: const TextStyle(color: Colors.grey)),
                      )));
}
