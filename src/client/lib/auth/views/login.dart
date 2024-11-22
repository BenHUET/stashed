import 'package:auth_repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:stashed/app/app.dart';
import 'package:stashed/auth/auth.dart';
import 'package:stashed/l10n/l10n.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(authRepository: context.read<AuthRepository>()),
      child: const LoginForm(),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = context.l10n;
    var theme = Theme.of(context);

    return BlocConsumer<LoginCubit, LoginState>(
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
        var cubit = context.read<LoginCubit>();

        return Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: l10n.inputEmailTitle,
                errorText: switch (state.email.displayError) {
                  EmailValidationError.empty => l10n.inputErrorEmpty,
                  EmailValidationError.malformed => l10n.inputErrorMalformed,
                  _ => null,
                },
              ),
              enabled: !state.status.isInProgressOrSuccess,
              onChanged: (value) => cubit.onEmailChanged(value),
              initialValue: state.email.value,
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: l10n.inputPasswordTitle,
                errorText: switch (state.password.displayError) {
                  PasswordValidationError.empty => l10n.inputErrorEmpty,
                  _ => null,
                },
              ),
              obscureText: true,
              enabled: !state.status.isInProgressOrSuccess,
              onChanged: (value) => cubit.onPasswordChanged(value),
              initialValue: state.password.value,
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
                child: Text(l10n.commonLogin),
              ),
            ),
            state.status.isInProgress ? Transform.scale(scale: 0.5, child: const CircularProgressIndicator()) : const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}
