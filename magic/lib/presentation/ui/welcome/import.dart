import 'package:flutter/material.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/domain/blockchain/mnemonic.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/services/services.dart';

enum ImportLifecycle {
  entering,
  form,
  validated,
  submitting,
  success,
  failed,
  exiting;

  String get msg {
    switch (this) {
      case ImportLifecycle.submitting:
        return 'Importing please wait';
      case ImportLifecycle.failed:
        return 'Import failed, try again?';
      case ImportLifecycle.success:
        return 'Success!';
      case ImportLifecycle.exiting:
        return ' ';
      default:
        return '';
    }
  }

  String get submitText {
    switch (this) {
      case ImportLifecycle.failed:
        return 'TRY AGAIN';
      case ImportLifecycle.success:
        return 'CLOSE';
      default:
        return 'SUBMIT';
    }
  }

  bool get submitEnabled => [
        ImportLifecycle.failed,
        ImportLifecycle.validated,
        ImportLifecycle.success
      ].contains(this);
  bool get animating => [
        ImportLifecycle.entering,
        ImportLifecycle.exiting,
      ].contains(this);
}

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  ImportPageState createState() => ImportPageState();
}

class ImportPageState extends State<ImportPage> {
  ImportLifecycle lifecycle = ImportLifecycle.entering;
  TextEditingController controller = TextEditingController();
  FocusNode textFocus = FocusNode();
  FocusNode submitFocus = FocusNode();
  bool validated = false;

  void toStage(ImportLifecycle stage) {
    if (mounted) {
      if (stage == ImportLifecycle.exiting) {
        cubits.app.animating = true;
        Future.delayed(slideDuration * 1.1, () {
          cubits.welcome.update(active: false, child: const SizedBox.shrink());
          cubits.app.animating = false;
        });
      }
      setState(() => lifecycle = stage);
    }
  }

  bool isValid(String value) =>
      validateMnemonic(value) || validatePrivateKey(value);

  void submit() async {
    final value = controller.text.trim();
    if (lifecycle == ImportLifecycle.validated) {
      toStage(ImportLifecycle.submitting);
      if ((validateMnemonic(value) && await cubits.keys.addMnemonic(value)) ||
          (validatePrivateKey(value) && await cubits.keys.addPrivKey(value))) {
        /// do we need to resetup our subscriptions? yes.
        /// all of them or just this wallet? just do all of them.
        await subscription.setupSubscriptions(cubits.keys.master);

        /// do we need to get all our assets again? yes.
        /// all of them or just this wallet? just do all of them.
        //cubits.wallet.clearAssets();
        await cubits.wallet.populateAssets();

        if (validateMnemonic(value)) {
          /// do we need to derive all our addresses? yes.
          /// all of them or just this wallet? we can specify just this wallet.
          deriveInBackground(value);
          // why not use this like we do on startup...?
          //cubits.receive.deriveAll([
          //  Blockchain.ravencoinMain,
          //  Blockchain.evrmoreMain,
          //]);
        }

        /// we always default to the first wallet, so we don't need to do this.
        /// maybe we should default to the last one... it's the one we know they
        /// have backed up if any imported... in that case we should do this.
        //await cubits.receive
        //    .populateAddresses(Blockchain.ravencoinMain);
        //await cubits.receive
        //    .populateAddresses(Blockchain.evrmoreMain);
        toStage(ImportLifecycle.success);
      } else {
        toStage(ImportLifecycle.failed);
      }
    } else if (lifecycle == ImportLifecycle.failed) {
      if (isValid(value)) {
        toStage(ImportLifecycle.validated);
      } else {
        toStage(ImportLifecycle.form);
      }
    } else if (lifecycle == ImportLifecycle.success) {
      toStage(ImportLifecycle.exiting);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    textFocus.dispose();
    submitFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (lifecycle == ImportLifecycle.entering) {
        toStage(ImportLifecycle.form);
      }
    });
    return Stack(
      children: <Widget>[
        AnimatedPositioned(
          duration: slideDuration,
          curve: Curves.easeOutCubic,
          top: lifecycle.animating ? screen.height : 0,
          left: 0,
          right: 0,
          child: Container(
            alignment: Alignment.center,
            height: screen.height,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                color: AppColors.foreground),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white54),
                        onPressed: () => toStage(ImportLifecycle.exiting))),
                if (lifecycle.msg == '')
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: controller,
                        focusNode: textFocus,
                        maxLines: 4,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'Enter your seed phrase here',
                          hintStyle: const TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onTapOutside: (_) => submitFocus.requestFocus(),
                        onChanged: (value) {
                          if (lifecycle == ImportLifecycle.form &&
                              isValid(value.trim())) {
                            toStage(ImportLifecycle.validated);
                          } else if (lifecycle == ImportLifecycle.validated &&
                              !isValid(value.trim())) {
                            toStage(ImportLifecycle.form);
                          }
                        },
                        onEditingComplete: () => submitFocus.requestFocus(),
                        onSubmitted: (value) => submitFocus.requestFocus(),
                      ))
                else
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        lifecycle.msg,
                        textAlign: TextAlign.center,
                      )),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      focusNode: submitFocus,
                      onPressed: submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lifecycle.submitEnabled
                            ? Colors.lightGreen
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        lifecycle.submitText,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
