import 'package:flutter/material.dart';

class TextIconButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onPressed;
  final bool isDanger;

  const TextIconButton({
    required this.icon,
    required this.text,
    this.onPressed,
    this.isDanger = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: isDanger
          ? TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            )
          : null,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 5),
          Text(text),
        ],
      ),
    );
  }
}
