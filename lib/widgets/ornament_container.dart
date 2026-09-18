import 'package:flutter/material.dart';

class OrnamentContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color backgroundColor;

  const OrnamentContainer({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5A93C),
          width: 2,
        ), // Золотистая рамка
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5A93C).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -2,
            right: 0,
            child: Text(
              '══ ⚜ ══',
              style: TextStyle(
                color: const Color(0xFFE5A93C).withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
