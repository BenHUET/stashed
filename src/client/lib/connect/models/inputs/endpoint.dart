import 'package:formz/formz.dart';

enum EndpointValidationError { empty, malformed }

final class Endpoint extends FormzInput<String, EndpointValidationError> {
  const Endpoint.pure([super.value = '']) : super.pure();
  const Endpoint.dirty([super.value = '']) : super.dirty();

  @override
  EndpointValidationError? validator(String value) {
    if (value.isEmpty) return EndpointValidationError.empty;

    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty) {
      return EndpointValidationError.malformed;
    }
    return null;
  }
}
