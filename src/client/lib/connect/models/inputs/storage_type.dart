import 'package:formz/formz.dart';

enum StorageKind { local }

enum StorageTypeValidationError { empty }

final class StorageType extends FormzInput<StorageKind?, StorageTypeValidationError> {
  const StorageType.pure([super.value]) : super.pure();
  const StorageType.dirty([super.value]) : super.dirty();

  @override
  StorageTypeValidationError? validator(StorageKind? value) {
    if (value == null) return StorageTypeValidationError.empty;
    return null;
  }
}
