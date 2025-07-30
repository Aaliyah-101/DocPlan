import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'lib/images/doctordash.jpg',
          fit: BoxFit.cover,
        ),
        SafeArea(child: child),
      ],
    );
  }
}
