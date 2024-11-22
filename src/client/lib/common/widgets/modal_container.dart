import 'package:flutter/material.dart';

class ModalContainer extends StatelessWidget {
  final Widget child;
  final String title;
  final String? subtitle;

  const ModalContainer({required this.child, required this.title, this.subtitle, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 800,
        maxHeight: 1080,
      ),
      child: ScaffoldMessenger(
        child: Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                height: subtitle == null ? 50 : 80,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                    subtitle != null
                        ? Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.6)),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: child,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
