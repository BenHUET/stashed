import 'package:formz/formz.dart';

enum EmailValidationError { empty, tooLong, malformed }

final class Email extends FormzInput<String, EmailValidationError> {
  const Email.pure([super.value = '']) : super.pure();
  const Email.dirty([super.value = '']) : super.dirty();

  @override
  EmailValidationError? validator(String value) {
    if (value.isEmpty) return EmailValidationError.empty;
    if (!RegExp(r"^[^@]+@[^@]+\.[^@]+$").hasMatch(value)) return EmailValidationError.malformed;
    return null;
  }
}
