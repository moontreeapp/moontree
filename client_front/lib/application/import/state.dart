part of 'cubit.dart';

@immutable
class ImportFormState extends CubitState {
  final String words;
  final bool importEnabled;
  final String importFormatDetected;
  final String password;
  final String salt;
  final bool importVisible;
  final bool submittedAttempt;
  final ImportFormat detection;
  final FileDetails? file;
  final String? finalText;
  final String? finalAccountId;
  final bool isSubmitting;

  const ImportFormState({
    this.words = '',
    this.importEnabled = false,
    this.importFormatDetected = '',
    this.password = '',
    this.salt = '',
    this.importVisible = true,
    this.submittedAttempt = false,
    this.detection = ImportFormat.invalid,
    this.file,
    this.finalText,
    this.finalAccountId,
    this.isSubmitting = false,
  });

  @override
  String toString() => 'ImportFormState('
      'words: $words, '
      'importEnabled: $importEnabled, '
      'importFormatDetected: $importFormatDetected, '
      'password: $password, '
      'salt: $salt, '
      'importVisible: $importVisible, '
      'submittedAttempt: $submittedAttempt, '
      'detection: $detection, '
      'file: $file, '
      'finalText: $finalText, '
      'finalAccountId: $finalAccountId, '
      'isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        words,
        importEnabled,
        importFormatDetected,
        password,
        salt,
        importVisible,
        submittedAttempt,
        detection,
        file,
        finalText,
        finalAccountId,
        isSubmitting,
      ];

  factory ImportFormState.initial() => ImportFormState();

  ImportFormState load({
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
  }) =>
      ImportFormState(
        words: words ?? this.words,
        importEnabled: importEnabled ?? this.importEnabled,
        importFormatDetected: importFormatDetected ?? this.importFormatDetected,
        password: password ?? this.password,
        salt: salt ?? this.salt,
        importVisible: importVisible ?? this.importVisible,
        submittedAttempt: submittedAttempt ?? this.submittedAttempt,
        detection: detection ?? this.detection,
        file: file ?? this.file,
        finalText: finalText ?? this.finalText,
        finalAccountId: finalAccountId ?? this.finalAccountId,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}
