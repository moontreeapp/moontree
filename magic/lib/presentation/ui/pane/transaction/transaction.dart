import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/pane/transaction/cubit.dart';
import 'package:magic/presentation/ui/pane/transaction/page.dart';

class Transaction extends StatelessWidget {
  const Transaction({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TransactionCubit, TransactionState>(
          builder: (BuildContext context, TransactionState state) =>
              state.transitionWidgets(state,
                  onEntering: const TransactionPage(),
                  onEntered: const TransactionPage(),
                  onExiting: const SizedBox.shrink(),
                  onExited: const SizedBox.shrink()));
}
