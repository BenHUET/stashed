import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:servers_repository/servers_repository.dart';
import 'package:stashed/app/app.dart';
import 'package:stashed/connect/connect.dart';
import 'package:stashed/l10n/l10n.dart';

class NewServerPage extends StatelessWidget {
  const NewServerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewServerCubit.add(serversRepository: context.read<ServersRepository>()),
      child: const _ServerForm(),
    );
  }
}

class EditServerPage extends StatelessWidget {
  final Server toEdit;

  const EditServerPage({required this.toEdit, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewServerCubit.edit(serversRepository: context.read<ServersRepository>(), server: toEdit),
      child: const _ServerForm(),
    );
  }
}

class _ServerForm extends StatelessWidget {
  const _ServerForm();

  @override
  Widget build(BuildContext context) {
    var l10n = context.l10n;
    var theme = Theme.of(context);

    return BlocConsumer<NewServerCubit, NewServerState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          context.pop();
        } else if (state.status.isFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.commonErrorMessage,
                style: TextStyle(
                  color: theme.colorScheme.onError,
                ),
              ),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        var cubit = context.read<NewServerCubit>();

        return Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: l10n.inputLabelTitle,
                errorText: switch (state.label.displayError) {
                  LabelValidationError.empty => l10n.inputErrorEmpty,
                  LabelValidationError.tooLong => l10n.inputErrorTooLong(state.label.maxSize),
                  _ => null,
                },
              ),
              enabled: !state.status.isInProgressOrSuccess,
              onChanged: (value) => cubit.onLabelChanged(value),
              initialValue: state.label.value,
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: l10n.inputEndpointTitle,
                errorText: switch (state.endpoint.displayError) {
                  EndpointValidationError.empty => l10n.inputErrorEmpty,
                  EndpointValidationError.malformed => l10n.inputErrorMalformed,
                  _ => null,
                },
              ),
              enabled: !state.status.isInProgressOrSuccess,
              onChanged: (value) => cubit.onEndpointChanged(value),
              initialValue: state.endpoint.value,
            ),
            const SizedBox(height: spacingHeight),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: state.status.isInProgressOrSuccess || !state.isValid
                    ? null
                    : () async {
                        await cubit.submitForm();
                      },
                child: Text(l10n.commonSave),
              ),
            ),
            state.status.isInProgress ? Transform.scale(scale: 0.5, child: const CircularProgressIndicator()) : const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}
