import 'package:auth_repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stashed/auth/auth.dart';
import 'package:stashed/common/common.dart';
import 'package:stashed/l10n/l10n.dart';

class AuthWidget extends StatelessWidget {
  const AuthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(authRepository: context.read<AuthRepository>())..getUser(),
      child: const AuthWidgetView(),
    );
  }
}

class AuthWidgetView extends StatelessWidget {
  const AuthWidgetView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        var l10n = context.l10n;
        var theme = Theme.of(context);
        var cubit = context.read<AuthCubit>();

        switch (state.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return Text(l10n.commonLoading);
          case AuthStatus.unauthenticated:
            return TextIconButton(
              icon: Icons.login_outlined,
              text: l10n.identityLoginLabel,
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext _) {
                    var l10n = context.l10n;
                    return Dialog(
                      clipBehavior: Clip.hardEdge,
                      child: ModalContainer(
                        title: l10n.identityLoginModalTitle,
                        child: const LoginPage(),
                      ),
                    );
                  },
                );
              },
            );
          case AuthStatus.authenticated:
            return TextIconButton(
              icon: Icons.logout_outlined,
              text: state.user!.username,
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text(l10n.authLogoutDialogTitle),
                    content: Text(l10n.authLogoutDialogMessage),
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(false),
                        child: Text(l10n.authLogoutDialogCancel),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        onPressed: () => context.pop(true),
                        child: Text(l10n.authLogoutDialogConfirm),
                      ),
                    ],
                  ),
                );

                if (result != null && result) {
                  await cubit.logout();
                }
              },
            );
        }
      },
    );
  }
}
