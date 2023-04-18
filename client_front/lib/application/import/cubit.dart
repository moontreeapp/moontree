//todo: merge the streams and listener into this.

import 'dart:async';
import 'package:tuple/tuple.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/services/import.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/streams/import.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/services/wallet/constants.dart';
import 'package:client_front/infrastructure/services/storage.dart';
import 'package:client_front/application/common.dart';

part 'state.dart';

class ImportFormCubit extends Cubit<ImportFormState> with SetCubitMixin {
  ImportFormCubit() : super(ImportFormState.initial());

  @override
  Future<void> reset() async => emit(ImportFormState.initial());

  @override
  ImportFormState submitting() => state.load(isSubmitting: true);

  @override
  Future<void> enter() async {
    emit(state);
  }

  @override
  void set({
    String? words,
    bool? importEnabled,
    String? importFormatDetected,
    String? password,
    String? salt,
    bool? importVisible,
    bool? submittedAttempt,
    ImportFormat? detection,
    FileDetails? file,
    String? finalText,
    String? finalAccountId,
    bool? isSubmitting,
  }) {
    emit(state.load(
      words: words,
      importEnabled: importEnabled,
      importFormatDetected: importFormatDetected,
      password: password,
      salt: salt,
      importVisible: importVisible,
      submittedAttempt: submittedAttempt,
      detection: detection,
      file: file,
      finalText: finalText,
      finalAccountId: finalAccountId,
      isSubmitting: isSubmitting,
    ));
  }

  bool validateValue(String? given) =>
      services.wallet.import.detectImportType((given ?? state.words).trim()) !=
      ImportFormat.invalid;

  void enableImport({String? given}) {
    String words = (given ?? state.words);
    final detection = services.wallet.import.detectImportType(words.trim());
    final importEnabled = detection != ImportFormat.invalid;
    late String? importFormatDetected;
    if (importEnabled) {
      importFormatDetected =
          'format recognized as ${detection.toString().split('.')[1]}';
    } else {
      importFormatDetected = '';
    }
    if (detection == ImportFormat.mnemonic) {
      words = state.words.toLowerCase();
    } else if (detection == ImportFormat.invalid) {
      importFormatDetected = 'Unknown';
    }
    set(
      detection: detection,
      importEnabled: importEnabled,
      importFormatDetected: importFormatDetected,
      words: words,
    );
  }

  Future<void> initiateImportProcess(ImportRequest? importRequest) async {
    bool firstWallet = false;
    if (pros.wallets.records.length == 1 && pros.balances.records.isEmpty) {
      /// don't remove just set it as preferred.
      //await pros.wallets.remove(pros.wallets.records.first);
      firstWallet = true;
    }
    final ImportFrom importFrom = ImportFrom(text: importRequest!.text);
    if (importFrom.importFormat != ImportFormat.invalid) {
      streams.client.busy.add(true);
      final Tuple3<List<bool>, List<String?>, List<String?>> tuple3 =
          await importFrom.handleImport(
        importRequest.getEntropy,
        importRequest.saveSecret,
      ); // successes, titles, msgs
      // success on all
      if (tuple3.item1.every((bool element) => element)) {
        if (importRequest.onSuccess != null) {
          await importRequest.onSuccess!();
        }
        if (firstWallet) {
          await pros.settings
              .savePreferredWalletId(pros.wallets.records.first.id);
          firstWallet = false;
        }
        // used in navbar ('import' or 'send')
        streams.import.result.add(ImportRequest(text: 'sensitive'));
        streams.app.behavior.snack.add(Snack(message: 'Sucessful Import'));
      } else {
        // notify about failures:
        for (final x in range(tuple3.item1.length)) {
          if (tuple3.item1[x]) {
            continue;
          } else if (tuple3.item3.isNotEmpty &&
              tuple3.item3.first != 'Success!') {
            streams.app.behavior.snack.add(Snack(
                message: tuple3.item3[x]
                    //.firstWhere((String? element) => element != null)
                    //?.split(': ')
                    //.first
                    ??
                    'Error Importing',
                //details: importFrom.importedMsg!, // good usecase for details
                positive: true));
          }
        }
      }
    }
  }
}
