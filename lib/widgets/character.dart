import 'package:flutter/material.dart';

import '../models/player.dart';

class CharacterWidget extends StatelessWidget {
  final Player player;
  final double size;

  const CharacterWidget({super.key, required this.player, this.size = 190});

  static const skin = [
    Color(0xFFF6C7A6),
    Color(0xFFE8AA7E),
    Color(0xFFC9825A),
    Color(0xFF9B5E3C),
    Color(0xFF6F422F),
  ];

  static const hair = [
    Color(0xFF191919),
    Color(0xFF5A351F),
    Color(0xFF8B5A2B),
    Color(0xFFD4A017),
    Color(0xFF8E3B2F),
  ];

  static const clothes = [
    Color(0xFF0F766E),
    Color(0xFF334155),
    Color(0xFF8B5CF6),
    Color(0xFFB45309),
    Color(0xFF166534),
    Color(0xFF991B1B),
    Color(0xFF1D4ED8),
  ];

  @override
  Widget build(BuildContext context) {
    final s = size / 190;
    final skinColor = skin[player.skinColor.clamp(0, skin.length - 1)];
    final hairColor = hair[player.hairColor.clamp(0, hair.length - 1)];
    final clothesColor = clothes[player.clothes.clamp(0, clothes.length - 1)];

    return SizedBox(
      width: size,
      height: size * 1.18,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: size * .68,
            child: CustomPaint(
              size: Size(size * .92, size * .50),
              painter: _BodyPainter(color: clothesColor, scale: s),
            ),
          ),
          Positioned(
            top: size * .22,
            child: Container(
              width: size * .52,
              height: size * .58,
              decoration: BoxDecoration(
                color: skinColor,
                borderRadius: BorderRadius.circular(size * .24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.10),
                    blurRadius: 8,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: size * .39,
            left: size * .35,
            child: Container(
              width: size * .055,
              height: size * .055,
              decoration: BoxDecoration(
                color: const Color(0xFF292929),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            top: size * .39,
            right: size * .35,
            child: Container(
              width: size * .055,
              height: size * .055,
              decoration: BoxDecoration(
                color: const Color(0xFF292929),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            top: size * .51,
            child: Container(
              width: size * .14,
              height: size * .035,
              decoration: BoxDecoration(
                color: const Color(0xFF8E4E3B),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            top: size * .12,
            child: _Hair(
              style: player.hairStyle,
              color: hairColor,
              size: size * .62,
            ),
          ),
          if (player.glasses != 0)
            Positioned(
              top: size * .35,
              child: _Glasses(style: player.glasses, size: size * .40),
            ),
          if (player.gender == 'female' && player.hairStyle == 4)
            Positioned(
              top: size * .22,
              left: size * .17,
              child: Text('🎀', style: TextStyle(fontSize: size * .17)),
            ),
        ],
      ),
    );
  }
}

class _Hair extends StatelessWidget {
  final int style;
  final Color color;
  final double size;

  const _Hair({required this.style, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case 1:
        return Container(
          width: size * .72,
          height: size * .38,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size),
          ),
        );
      case 2:
        return Container(
          width: size * .86,
          height: size * .30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: size * .18,
              height: size * .30,
              color: color,
            ),
          ),
        );
      case 3:
        return Container(
          width: size * .70,
          height: size * .52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size),
          ),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: size * .20,
              height: size * .46,
              color: color,
            ),
          ),
        );
      case 4:
        return Container(
          width: size * .92,
          height: size * .56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size),
          ),
        );
      default:
        return Container(
          width: size * .66,
          height: size * .27,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size),
          ),
        );
    }
  }
}

class _Glasses extends StatelessWidget {
  final int style;
  final double size;

  const _Glasses({required this.style, required this.size});

  @override
  Widget build(BuildContext context) {
    final dark = style == 2;
    return Row(
      children: [
        _Lens(size: size * .43, dark: dark),
        SizedBox(width: size * .08),
        _Lens(size: size * .43, dark: dark),
      ],
    );
  }
}

class _Lens extends StatelessWidget {
  final double size;
  final bool dark;

  const _Lens({required this.size, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * .58,
      decoration: BoxDecoration(
        color: dark ? const Color(0xCC111827) : Colors.white.withOpacity(.35),
        border: Border.all(color: const Color(0xFF111827), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _BodyPainter extends CustomPainter {
  final Color color;
  final double scale;

  _BodyPainter({required this.color, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(8 * scale, 0, size.width - 16 * scale, size.height),
      Radius.circular(32 * scale),
    );
    canvas.drawRRect(r, paint);
    final collar = Paint()..color = Colors.white.withOpacity(.20);
    canvas.drawCircle(Offset(size.width / 2, 12 * scale), 18 * scale, collar);
  }

  @override
  bool shouldRepaint(covariant _BodyPainter oldDelegate) =>
      oldDelegate.color != color;
}
