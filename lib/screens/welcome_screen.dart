import 'package:flutter/material.dart';

import 'language_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Плавное появление элементов после загрузки
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Градиентный фоновый слой
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F766E), // Глубокий бирюзовый
                  Color(0xFF064E3B), // Тёмно-изумрудный
                  Color(0xFF022C22),
                ],
              ),
            ),
          ),

          // 2. Декоративные казахские орнаменты на фоне
          Positioned(
            top: -40,
            right: -40,
            child: _OrnamentCircle(size: 220, opacity: 0.08),
          ),
          Positioned(
            bottom: -60,
            left: -50,
            child: _OrnamentCircle(size: 280, opacity: 0.06),
          ),

          // 3. Основной контент
          SafeArea(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _visible ? 1.0 : 0.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    const Spacer(),

                    // Эффектное лого с неоновым свечением и орнаментным рамкой
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2DD4BF).withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 105,
                          height: 105,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2DD4BF), Color(0xFF0F766E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: const Color(0xFFFDE047)
                                  .withOpacity(0.6), // Золотистая окантовка
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Q',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 60,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Заголовок бренда с тонкой золотой плашкой
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          '✦  ',
                          style: TextStyle(
                            color: Color(0xFFFDE047),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Qazaqsha',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '  ✦',
                          style: TextStyle(
                            color: Color(0xFFFDE047),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Слоган на казахском
                    const Text(
                      'Қазақ тілін үйренудің\nжаңа жолы',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE6F4F1),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Бейдж-теги с функционалом приложения
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: const Text(
                        'Учись  •  Играй  •  Развивай героя',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF99F6E4),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Главная яркая кнопка
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LanguageScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFFDE047,
                          ), // Золотисто-жёлтый акцент
                          foregroundColor: const Color(0xFF022C22),
                          elevation: 8,
                          shadowColor: const Color(0xFFFDE047).withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Бастау / Начать',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 22),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Фоновый виджет с имитацией геометрического казахского орнамента
class _OrnamentCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _OrnamentCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 14),
        ),
        child: Center(
          child: Container(
            width: size * 0.65,
            height: size * 0.65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 8),
            ),
          ),
        ),
      ),
    );
  }
}
