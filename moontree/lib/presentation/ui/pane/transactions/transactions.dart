import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/cubits/transactions/cubit.dart';
import 'package:moontree/presentation/ui/pane/transactions/page.dart';
import 'package:moontree/presentation/utils/animation.dart';
import 'package:moontree/presentation/widgets/animations/fading.dart';

class Transactions extends StatelessWidget {
  const Transactions({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TransactionsCubit, TransactionsState>(
          buildWhen: (TransactionsState previous, TransactionsState current) =>
              previous.active != current.active ||
              (!previous.active && !current.active),
          builder: (context, state) {
            if (state.wasInactive && state.active) {
              const child = TransactionsPage();
              cubits.transactions.update(child: child);
              return child;
              //const FadeIn(child: child);
            }
            if (state.wasActive && !state.active) {
              WidgetsBinding.instance.addPostFrameCallback((_) =>
                  Future.delayed(fadeDuration,
                      () => cubits.transactions.update(active: false)));
              //return FadeOut(child: state.child);
              return state.child;
            }
            if (state.wasActive && state.active) {
              return state.child;
            }
            const child = SizedBox.shrink();
            cubits.transactions.update(child: child);
            return child;
          });
}
