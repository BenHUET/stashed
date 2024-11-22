import 'package:formz/formz.dart';

enum LabelValidationError { empty, tooLong }

final class Label extends FormzInput<String, LabelValidationError> {
  const Label.pure([super.value = '']) : super.pure();
  const Label.dirty([super.value = '']) : super.dirty();

  final int maxSize = 12;

  @override
  LabelValidationError? validator(String value) {
    if (value.isEmpty) return LabelValidationError.empty;
    if (value.length > maxSize) return LabelValidationError.tooLong;
    return null;
  }
}
