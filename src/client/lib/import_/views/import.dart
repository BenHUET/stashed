import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_repository/media_repository.dart';
import 'package:path/path.dart' as p;
import 'package:stashed/app/app.dart';
import 'package:stashed/common/common.dart';
import 'package:stashed/import_/cubits/import_cubit.dart';
import 'package:stashed/l10n/l10n.dart';
import 'package:tasks_repository/tasks_repository.dart';
import 'package:vaults_repository/vaults_repository.dart';

class ImportPage extends StatelessWidget {
  const ImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ImportCubit(
        tasksRepository: context.read<TasksRepository>(),
        mediaRepository: context.read<MediaRepository>(),
        vaultsRepository: context.read<VaultsRepository>(),
      ),
      child: const _ImportView(),
    );
  }
}

class _ImportView extends StatelessWidget {
  const _ImportView();

  @override
  Widget build(BuildContext context) {
    var l10n = context.l10n;
    var theme = Theme.of(context);

    return BlocConsumer<ImportCubit, ImportState>(
      listener: (context, state) {
        if (state.status == ImportStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.commonErrorMessage, style: TextStyle(color: theme.colorScheme.onError)),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        } else if (state.status == ImportStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.commonQueuedMessage(state.importedCount)),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ImportCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Wrap(
                        children: [
                          TextIconButton(
                            icon: Icons.upload_file_outlined,
                            text: l10n.importAddFiles,
                            onPressed: () async {
                              await cubit.addFiles();
                            },
                          ),
                          TextIconButton(
                            icon: Icons.drive_folder_upload_outlined,
                            text: l10n.importAddDirectory,
                            onPressed: () async {
                              await cubit.addDirectory();
                            },
                          ),
                          TextIconButton(
                            icon: Icons.delete_outlined,
                            text: l10n.importClearAll,
                            onPressed: () async {
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text(l10n.importClearAllDialogTitle),
                                  content: Text(l10n.importClearAllDialogMessage),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text(l10n.importClearAllDialogCancel),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Theme.of(context).colorScheme.error,
                                      ),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text(l10n.importClearAllDialogConfirm),
                                    ),
                                  ],
                                ),
                              );

                              if (result != null && result) {
                                await cubit.clearAll();
                              }
                            },
                            isDanger: true,
                          )
                        ],
                      ),
                      const VaultsPicker(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: spacingHeight),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: state.files
                    .map(
                      (file) => Card(
                        child: ListTile(
                          leading: MimeIcon(filename: file),
                          title: Text(
                            p.basename(file),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            p.dirname(file),
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: TextIconButton(
                            icon: Icons.delete_outlined,
                            text: l10n.commonRemove,
                            isDanger: true,
                            onPressed: () async {
                              await cubit.removeFile(file);
                            },
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: spacingHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextIconButton(
                  icon: Icons.upload,
                  text: l10n.importImport(state.files.length, state.selectedVaults.length),
                  onPressed: state.files.isNotEmpty && state.selectedVaults.isNotEmpty && state.status != ImportStatus.loading
                      ? () {
                          cubit.import();
                        }
                      : null,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
