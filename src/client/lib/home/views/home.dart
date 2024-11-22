import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stashed/appbar/appbar.dart' as a;

class HomeView extends StatelessWidget {
  final StatefulNavigationShell _navigationShell;

  const HomeView(this._navigationShell, {super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: a.AppBarWidget(_navigationShell),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _navigationShell,
        ),
      ),
    );
  }
}
