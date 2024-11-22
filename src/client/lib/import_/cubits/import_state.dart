part of 'import_cubit.dart';

enum ImportStatus { initial, loading, success, failure }

class ImportState extends Equatable {
  final ImportStatus status;
  final Set<String> files;
  final int importedCount;
  final List<Vault> selectedVaults;

  const ImportState({
    this.status = ImportStatus.initial,
    this.files = const {},
    this.importedCount = 0,
    this.selectedVaults = const [],
  });

  ImportState copyWith({
    ImportStatus? status,
    Set<String>? files,
    int? importedCount,
    List<Vault>? selectedVaults,
  }) {
    return ImportState(
      status: status ?? this.status,
      files: files ?? this.files,
      importedCount: importedCount ?? this.importedCount,
      selectedVaults: selectedVaults ?? this.selectedVaults,
    );
  }

  @override
  List<Object> get props => [status, files, importedCount, selectedVaults];
}
