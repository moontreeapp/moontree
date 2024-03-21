import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubits.dart';

class WalletFeedPage extends StatelessWidget {
  const WalletFeedPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<WalletFeedCubit, WalletFeedState>(
          builder: (BuildContext context, WalletFeedState state) =>
              Container(height: 200, width: 200, color: Colors.red));
}
