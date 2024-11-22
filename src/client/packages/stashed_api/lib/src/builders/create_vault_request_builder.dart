import 'package:stashed_api/src/dtos/create_file_vault_request.dart';
import 'package:stashed_api/src/dtos/create_local_storage_request.dart';
import 'package:stashed_api/src/dtos/create_vault_request.dart';

class CreateVaultRequestBuilder {
  var _request = const CreateVaultRequestDTO();
  CreateVaultRequestDTO get request => _request;

  void withFileVault({required String label, String? databaseDirectory}) {
    _request = _request.copyWith(fileVault: CreateFileVaultRequestDTO(label: label, databaseDirectory: databaseDirectory));
  }

  void withLocalStorage({String? filesDirectory}) {
    _request = _request.copyWith(localStorage: CreateLocalStorageRequestDTO(filesDirectory: filesDirectory));
  }
}
