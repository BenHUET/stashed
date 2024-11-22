import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stashed/connect/connect.dart';
import 'package:stashed/home/home.dart';
import 'package:stashed/import_/import.dart';
import 'package:stashed/search/search.dart';
import 'package:stashed/splash/splash.dart';
import 'package:stashed/tasks/tasks.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (_, __, navigationShell) => HomeView(navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/connect',
              builder: (context, __) => const ConnectPage(),
            )
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, __) => const SearchPage(),
            )
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/import',
              builder: (context, __) => const ImportPage(),
            )
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              builder: (context, __) => const TasksPage(),
            )
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, __) => const Placeholder(color: Colors.purple),
            )
          ],
        ),
      ],
    ),
  ],
);
