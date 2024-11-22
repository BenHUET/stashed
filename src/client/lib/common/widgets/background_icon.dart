import 'package:flutter/material.dart';

class BackgroundIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const BackgroundIcon({
    required this.icon,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
