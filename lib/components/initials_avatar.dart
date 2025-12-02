import 'package:flutter/material.dart';

class InitialsAvatar extends StatelessWidget {
  final String name;
  final double? size;
  final double? fontSize;

  const InitialsAvatar({
    super.key,
    required this.name,
    this.size,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    String initials = "";
    if (name.isNotEmpty) {
      final trimmed = name.trim();
      if (trimmed.length >= 2) {
        initials = trimmed.substring(0, 2).toUpperCase();
      } else if (trimmed.isNotEmpty) {
        initials = trimmed.substring(0, 1).toUpperCase();
      } else {
        initials = "?";
      }
    }

    final List<Color> colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.blueGrey,
    ];

    final color = colors[name.hashCode.abs() % colors.length];

    return Container(
      width: size ?? double.infinity,
      height: size ?? double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: fontSize ?? 18,
          ),
        ),
      ),
    );
  }
}
