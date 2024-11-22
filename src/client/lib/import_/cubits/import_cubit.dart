import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_selector/file_selector.dart';
import 'package:logging/logging.dart';
import 'package:media_repository/media_repository.dart';
import 'package:path/path.dart' as p;
import 'package:tasks_repository/tasks_repository.dart';
import 'package:vaults_repository/vaults_repository.dart';

part 'import_state.dart';

class ImportCubit extends Cubit<ImportState> {
  final Logger _logger = Logger((ImportCubit).toString());
  final TasksRepository _tasksRepository;
  final MediaRepository _mediaRepository;
  final VaultsRepository _vaultsRepository;
  String? _lastDirectory;

  ImportCubit({
    required TasksRepository tasksRepository,
    required MediaRepository mediaRepository,
    required VaultsRepository vaultsRepository,
  })  : _tasksRepository = tasksRepository,
        _mediaRepository = mediaRepository,
        _vaultsRepository = vaultsRepository,
        super(const ImportState()) {
    _vaultsRepository.getSelectedVaults().listen(
      (vaults) {
        emit(state.copyWith(selectedVaults: vaults));
      },
    );
  }

  Future<void> addFiles() async {
    final results = await openFiles(initialDirectory: _lastDirectory);
    final newFiles = results.map((e) => e.path);
    final allFiles = {...state.files, ...newFiles};

    if (newFiles.isNotEmpty) {
      _lastDirectory = p.dirname(newFiles.first);
    }

    emit(state.copyWith(files: allFiles));
  }

  Future<void> addDirectory() async {
    final results = await getDirectoryPaths(initialDirectory: _lastDirectory);
    final directories = results.nonNulls.toList();

    if (directories.isNotEmpty) {
      _lastDirectory = p.dirname(directories.last);
    }

    var files = {...state.files};
    for (var directory in directories) {
      final dir = Directory(directory);
      final entities = await dir.list(recursive: true).toList();
      files.addAll(entities.whereType<File>().map((e) => e.path).toList());
    }

    emit(state.copyWith(files: files));
  }

  Future<void> clearAll() async {
    emit(state.copyWith(files: {}));
  }

  Future<void> removeFile(String file) async {
    final files = {...state.files};
    files.remove(file);
    emit(state.copyWith(files: files));
  }

  Future<void> import() async {
    emit(state.copyWith(status: ImportStatus.loading));

    final files = {...state.files};
    var taskCount = 0;

    try {
      while (files.isNotEmpty) {
        final file = files.first;
        files.remove(file);

        for (var vault in _vaultsRepository.selectedVaults) {
          final task = ClientTaskImport(
            task: () => _mediaRepository.importMedia(vault.address, vault.id, file),
            file: p.basename(file),
            vaultLabel: vault.label,
          );
          _tasksRepository.queue(task);
          taskCount++;
        }

        emit(state.copyWith(files: files));
      }

      emit(state.copyWith(status: ImportStatus.success, importedCount: taskCount));
      emit(state.copyWith(status: ImportStatus.initial, importedCount: 0));
    } catch (e, st) {
      _logger.log(Level.SHOUT, e, st);
      emit(state.copyWith(status: ImportStatus.failure));
    }
  }
}
