import 'package:auth_repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servers_repository/servers_repository.dart';
import 'package:stashed/l10n/l10n.dart';
import 'package:stashed/splash/splash.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit(context.read<ServersRepository>(), context.read<AuthRepository>()),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.primary,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'stashed',
                style: Theme.of(context).textTheme.displayLarge!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
              ),
              BlocConsumer<SplashCubit, SplashState>(
                listener: (context, state) {
                  if (state.status == SplashStatus.success) {
                    context.go('/connect');
                  }
                },
                builder: (context, state) {
                  late String text;
                  switch (state.status) {
                    case SplashStatus.initial:
                    case SplashStatus.initializing:
                    case SplashStatus.success:
                      text = context.l10n.splashMessageInitializing;
                    case SplashStatus.failure:
                      text = context.l10n.splashMessageFailure;
                  }

                  return Text(
                    text,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
