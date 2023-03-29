import 'package:client_front/application/send/cubit.dart';
import 'package:client_front/presentation/widgets/back/coinspec/spec.dart';
import 'package:flutter/material.dart';
import 'package:client_front/presentation/services/services.dart' show screen;
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:flutter_bloc/flutter_bloc.dart';

class BackSendScreen extends StatelessWidget {
  final String chainSymbol;
  const BackSendScreen({Key? key, this.chainSymbol = ''})
      : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('backSend');

  @override
  Widget build(BuildContext context) => Container(
        height: screen.frontContainer.inverseMid,
        //color: Colors.transparent,
        alignment: Alignment.center,
        child: CoinSendHeader(),
      );
}

class CoinSendHeader extends StatelessWidget {
  const CoinSendHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SimpleSendFormCubit cubit =
        BlocProvider.of<SimpleSendFormCubit>(context);
    return BlocBuilder<SimpleSendFormCubit, SimpleSendFormState>(
        bloc: cubit..enter(),
        builder: (BuildContext context, SimpleSendFormState state) {
          return CoinSpec(
              cubit: cubit,
              pageTitle: 'Send',
              security: cubit.state.security,
              color: Theme.of(context).backgroundColor);
        });
  }
}
