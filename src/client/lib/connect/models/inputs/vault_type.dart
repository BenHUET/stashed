import 'package:formz/formz.dart';

enum VaultKind { file }

enum VaultTypeValidationError { empty }

final class VaultType extends FormzInput<VaultKind?, VaultTypeValidationError> {
  const VaultType.pure([super.value]) : super.pure();
  const VaultType.dirty([super.value]) : super.dirty();

  @override
  VaultTypeValidationError? validator(VaultKind? value) {
    if (value == null) return VaultTypeValidationError.empty;
    return null;
  }
}
