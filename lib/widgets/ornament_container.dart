import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OrnamentContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  const OrnamentContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.gold.withOpacity(.55)),
      ),
      child: Stack(children: [
        Positioned(right: 0, top: -4, child: Text('✦', style: TextStyle(color: AppTheme.gold.withOpacity(.6), fontSize: 18))),
        child,
      ]),
    );
  }
}
