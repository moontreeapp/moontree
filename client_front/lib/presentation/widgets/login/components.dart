import 'package:client_back/services/consent.dart';
import 'package:client_front/application/login/cubit.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:url_launcher/url_launcher.dart';

class MoontreeLogo extends StatelessWidget {
  const MoontreeLogo({super.key});
  @override
  Widget build(BuildContext context) => Container(
        child: SvgPicture.asset('assets/logo/moontree_logo.svg'),
        height: .1534.ofMediaHeight(context),
        // height: 110.figma(context),
      );
}

class WelcomeMessage extends StatelessWidget {
  const WelcomeMessage({super.key});
  @override
  Widget build(BuildContext context) => Text('Moontree',
      style: Theme.of(context)
          .textTheme
          .headline1
          ?.copyWith(color: AppColors.black60));
}

/// this should be connected to a cubit.
class AggrementCheckbox extends StatelessWidget {
  const AggrementCheckbox({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<LoginCubit, LoginCubitState>(
          builder: (context, bottomModalSheetState) => Checkbox(
                //checkColor: Colors.white,
                value: components.cubits.login.state.isConsented,
                onChanged: (bool? value) async =>
                    components.cubits.login.update(isConsented: true),
              ));
}

class UlaMessage extends StatelessWidget {
  const UlaMessage({super.key});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
              alignment: Alignment.center,
              width: 18,
              child: AggrementCheckbox()),
          Container(
              alignment: Alignment.center,
              width: .70.ofMediaWidth(context),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(components.routes.routeContext!)
                      .textTheme
                      .bodyText2,
                  children: <TextSpan>[
                    const TextSpan(text: "I agree to Moontree's\n"),
                    TextSpan(
                        text: 'User Agreement',
                        style: Theme.of(components.routes.routeContext!)
                            .textTheme
                            .underlinedLink,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse(documentEndpoint(
                                ConsentDocument.user_agreement)));
                          }),
                    const TextSpan(text: ', '),
                    TextSpan(
                        text: 'Privacy Policy',
                        style: Theme.of(components.routes.routeContext!)
                            .textTheme
                            .underlinedLink,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse(documentEndpoint(
                                ConsentDocument.privacy_policy)));
                          }),
                    const TextSpan(text: ',\n and '),
                    TextSpan(
                        text: 'Risk Disclosure',
                        style: Theme.of(components.routes.routeContext!)
                            .textTheme
                            .underlinedLink,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse(documentEndpoint(
                                ConsentDocument.risk_disclosures)));
                          }),
                  ],
                ),
              )),
          const SizedBox(
            width: 18,
          ),
        ],
      );
}
