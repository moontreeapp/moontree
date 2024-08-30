import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/pane/transactions/cubit.dart';
import 'package:magic/presentation/ui/pane/transactions/page.dart';
import 'package:magic/presentation/utils/animation.dart';

class Transactions extends StatelessWidget {
  const Transactions({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TransactionsCubit, TransactionsState>(
          buildWhen: (TransactionsState previous, TransactionsState current) =>
              previous.active != current.active ||
              (!previous.active && !current.active),
          builder: (context, state) => state.transitionFunctions(
                state,
                onEntering: () {
                  const child = TransactionsPage();
                  cubits.transactions.update(child: child);
                  return child;
                },
                onEntered: () => state.child,
                onExiting: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) =>
                      Future.delayed(fadeDuration,
                          () => cubits.transactions.update(active: false)));
                  return state.child;
                },
                onExited: () {
                  const child = SizedBox.shrink();
                  cubits.transactions.update(child: child);
                  return child;
                },
              ));
}
