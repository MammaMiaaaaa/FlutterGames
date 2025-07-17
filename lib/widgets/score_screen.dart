import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../screens/memory_match_screen.dart';
import '../screens/math_racer_screen.dart';
import '../screens/game_selection_screen.dart';

enum GameType {
  memoryMatch,
  mathRacer,
}

class ScoreScreen extends StatelessWidget {
  final String resultText;
  final String highScoreText;
  final VoidCallback onPlayAgain;
  final VoidCallback onReturn;
  final GameType gameType;
  const ScoreScreen({
    super.key,
    required this.resultText,
    required this.highScoreText,
    required this.onPlayAgain,
    required this.onReturn,
    required this.gameType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fireworks background
          const _FireworksBackground(),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                // Corgi mascot
                Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.2),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                        'assets/images/fox.png', // Replace with corgi image if available
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Result text
                Text(
                  resultText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontWeight: FontWeight.w600,
                    fontSize: 40,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 16),
                // High score text
                Text(
                  highScoreText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                    color: Colors.pinkAccent,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            textStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          onPressed: () {
                            // Play Again: push the correct game screen and reset state
                            switch (gameType) {
                              case GameType.memoryMatch:
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const MemoryMatchScreen()),
                                  (route) => false,
                                );
                                break;
                              case GameType.mathRacer:
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const MathRacerScreen()),
                                );
                                break;
                            }
                          },
                          child: const Text('Play Again'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            textStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const GameSelectionScreen()),
                              (route) => false,
                            );
                          },
                          child: const Text('Return'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FireworksBackground extends StatefulWidget {
  const _FireworksBackground();
  @override
  State<_FireworksBackground> createState() => _FireworksBackgroundState();
}

class _FireworksBackgroundState extends State<_FireworksBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _FireworksPainter(_controller.value),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

class _FireworksPainter extends CustomPainter {
  final double progress;
  _FireworksPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final List<Color> colors = [
      Colors.pinkAccent,
      Colors.orangeAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.yellowAccent,
    ];
    final center = Offset(size.width / 2, size.height / 3);
    final random = [
      Offset(-120, -40),
      Offset(120, -40),
      Offset(-80, 80),
      Offset(80, 80),
      Offset(-160, 40),
      Offset(160, 40),
    ];
    for (int i = 0; i < colors.length; i++) {
      final angle = (progress * 2 * 3.14159) + (i * 3.14159 / 3);
      final radius = 80 + 40 * (1 + progress);
      final fireworkCenter = center + Offset(radius * (i.isEven ? 1 : -1), radius * (i.isOdd ? 1 : -1)) + random[i];
      for (int j = 0; j < 12; j++) {
        final particleAngle = angle + (j * 3.14159 / 6);
        final particleRadius = 30 + 40 * progress;
        final particleOffset = fireworkCenter + Offset(
          particleRadius * (progress) * (1.2 * (j.isEven ? 1 : -1)) * cos(particleAngle),
          particleRadius * (progress) * (1.2 * (j.isOdd ? 1 : -1)) * sin(particleAngle),
        );
        final paint = Paint()
          ..color = colors[i].withOpacity(1 - progress * 0.7)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(particleOffset, 8 - 5 * progress, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter oldDelegate) => true;
} 