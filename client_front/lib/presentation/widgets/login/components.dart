import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:client_back/services/consent.dart';
import 'package:client_front/application/app/login/cubit.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/presentation/services/services.dart' show screen;
import 'package:client_front/presentation/components/components.dart'
    as components;

class MoontreeLogo extends StatelessWidget {
  const MoontreeLogo({super.key});
  @override
  Widget build(BuildContext context) => Container(
        child: SvgPicture.asset('assets/logo/moontree_logo.svg'),
        height: .1534.ofMediaHeight(context),
      );
}

class WelcomeMessage extends StatelessWidget {
  final String text;
  const WelcomeMessage({super.key, this.text = 'Moontree'});
  @override
  Widget build(BuildContext context) => Text(text,
      style: Theme.of(context)
          .textTheme
          .displayLarge
          ?.copyWith(color: AppColors.black60));
}

class AggrementCheckbox extends StatelessWidget {
  const AggrementCheckbox({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<LoginCubit, LoginCubitState>(
          builder: (context, state) => Checkbox(
                //checkColor: Colors.white,
                value: state.isConsented,
                onChanged: (bool? value) async =>
                    context.read<LoginCubit>().update(isConsented: value),
              ));
}

class UlaMessage extends StatelessWidget {
  const UlaMessage({super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: screen.width - 16 - 16,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              width: 28,
              child: AggrementCheckbox(),
            ),
            Container(
              width: screen.width - 16 - 16 - 28 - 28,
              alignment: Alignment.center,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(components.routes.routeContext!)
                      .textTheme
                      .bodyMedium,
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
                        },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 28)
          ],
        ),
      );
}
