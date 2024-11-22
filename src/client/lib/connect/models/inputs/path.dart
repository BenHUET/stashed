import 'package:formz/formz.dart';

enum PathValidationError { empty, malformed }

class Path extends FormzInput<String, PathValidationError> {
  const Path.pure([super.value = '']) : super.pure();
  const Path.dirty([super.value = '']) : super.dirty();

  @override
  PathValidationError? validator(String value) {
    if (value == '') return null;
    return validatePath(value);
  }

  PathValidationError? validatePath(String value) {
    try {
      final uri = Uri.file(value);
      if (!uri.isAbsolute) return PathValidationError.malformed;
    } catch (_) {
      return PathValidationError.malformed;
    }

    return null;
  }
}

class RequiredPath extends Path {
  const RequiredPath.pure([super.value = '']) : super.pure();
  const RequiredPath.dirty([super.value = '']) : super.dirty();

  @override
  PathValidationError? validator(String value) {
    if (value.isEmpty) return PathValidationError.empty;
    return super.validatePath(value);
  }
}
