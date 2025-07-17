import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/score_screen.dart';
import '../screens/game_selection_screen.dart'; // Added import for GameSelectionScreen
import '../models/math_racer_game_provider.dart';
import 'package:provider/provider.dart';

class MathRacerScreen extends StatelessWidget {
  const MathRacerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MathRacerGameProvider(),
      child: const _MathRacerGameView(),
    );
  }
}

class _MathRacerGameView extends StatelessWidget {
  const _MathRacerGameView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MathRacerGameProvider>(
      builder: (context, provider, _) {
        // If the game is ended and not won, show the score screen (time up)
        if (provider.gameEnded && !provider.gameWon) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ModalRoute.of(context)?.isCurrent ?? false) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ScoreScreen(
                    resultText: 'Time Up!',
                    highScoreText: provider.highScore > 0
                        ? 'Best Time: ${provider.highScore ~/ 60}:${(provider.highScore % 60).toString().padLeft(2, '0')}'
                        : '',
                    onPlayAgain: () {},
                    onReturn: () {},
                    gameType: GameType.mathRacer,
                  ),
                ),
              );
            }
          });
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Math Racer'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/background/bg_grass.jpg',
                  fit: BoxFit.cover,
                ),
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // Rabbit Track
                      _AnimatedRunnerTrack(
                        label: 'Rabbit',
                        begin: provider.previousTimerProgress,
                        end: provider.timerProgress,
                        icon: Icons.pets, // Placeholder for rabbit
                        color: Colors.orange,
                        showLabel: true,
                      ),
                      const SizedBox(height: 16),
                      // Corgi Track
                      _AnimatedRunnerTrack(
                        label: 'Corgi',
                        begin: provider.previousPlayerProgress,
                        end: provider.playerProgress,
                        icon: Icons.pets, // Placeholder for corgi
                        color: Colors.brown,
                        showLabel: true,
                      ),
                      const SizedBox(height: 32),
                      // Question Box with instruction
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Pilih jawaban yang benar',
                              style: GoogleFonts.fredoka(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              provider.question.question,
                              style: GoogleFonts.fredoka(
                                fontWeight: FontWeight.w600,
                                fontSize: 28,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Answer Buttons
                      ...List.generate(4, (i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        child: _AnimatedAnswerButton(
                          key: Key('answer_button_$i'),
                          text: '${provider.question.options[i]}',
                          onPressed: provider.gameEnded ? null : () => _onAnswer(context, provider, provider.question.options[i]),
                        ),
                      )),
                      const Spacer(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onAnswer(BuildContext context, MathRacerGameProvider provider, int selected) {
    provider.answer(selected);
    if (provider.gameEnded) {
      // Show score screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ScoreScreen(
            resultText: provider.gameWon
                ? 'Finished in ${((MathRacerGameProvider.totalTime - provider.timeLeft) ~/ 60)}:${((MathRacerGameProvider.totalTime - provider.timeLeft) % 60).toString().padLeft(2, '0')}!'
                : 'Time Up!',
            highScoreText: provider.highScore > 0
                ? 'Best Time: ${provider.highScore ~/ 60}:${(provider.highScore % 60).toString().padLeft(2, '0')}'
                : '',
            onPlayAgain: () {}, // handled in ScoreScreen
            onReturn: () {},   // handled in ScoreScreen
            gameType: GameType.mathRacer,
          ),
        ),
      );
    }
  }
}

class _AnimatedRunnerTrack extends StatelessWidget {
  final String label;
  final double begin;
  final double end;
  final IconData icon;
  final Color color;
  final bool showLabel;
  const _AnimatedRunnerTrack({Key? key, required this.label, required this.begin, required this.end, required this.icon, required this.color, this.showLabel = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final barWidth = MediaQuery.of(context).size.width - 48 - 32;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Track background
            Container(
              height: 32,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3), width: 2),
              ),
            ),
            // Animated progress bar fill
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: begin, end: end),
              duration: const Duration(milliseconds: 400),
              builder: (context, value, child) {
                return Container(
                  height: 32,
                  width: barWidth * value.clamp(0.0, 1.0),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              },
            ),
            // Animated runner icon
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: begin, end: end),
              duration: const Duration(milliseconds: 400),
              builder: (context, value, child) {
                return Positioned(
                  left: barWidth * value.clamp(0.0, 1.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: color,
                        radius: 16,
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                      if (showLabel) ...[
                        const SizedBox(width: 8),
                        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MathQuestion {
  final String question;
  final int answer;
  final List<int> options;
  MathQuestion({required this.question, required this.answer, required this.options});

  static MathQuestion generate() {
    final rand = Random();
    int type = rand.nextInt(3);
    int a, b;
    int ans = 0;
    String q = '';
    switch (type) {
      case 0: // a + b = ?
        a = rand.nextInt(96) + 5;
        b = rand.nextInt(96) + 4;
        ans = a + b;
        if (ans > 100) {
          a = 100 - b;
          ans = a + b;
        }
        q = '$a + $b = ?';
        break;
      case 1: // a × ? = b
        a = rand.nextInt(12) + 2;
        ans = rand.nextInt(12) + 2;
        b = a * ans;
        q = '$a × ? = $b';
        break;
      case 2: // ? ÷ b = a
        b = rand.nextInt(12) + 2;
        a = rand.nextInt(12) + 2;
        ans = a * b;
        q = '? ÷ $b = $a';
        break;
    }
    Set<int> options = {ans};
    while (options.length < 4) {
      int fake = ans + rand.nextInt(21) - 10;
      if (fake < 0 || fake > 100 || options.contains(fake)) continue;
      options.add(fake);
    }
    List<int> opts = options.toList()..shuffle();
    return MathQuestion(question: q, answer: ans, options: opts);
  }
}

class _AnimatedAnswerButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  const _AnimatedAnswerButton({Key? key, required this.text, required this.onPressed}) : super(key: key);

  @override
  State<_AnimatedAnswerButton> createState() => _AnimatedAnswerButtonState();
}

class _AnimatedAnswerButtonState extends State<_AnimatedAnswerButton> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() {
        _pressed = true;
      });
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() {
        _pressed = false;
      });
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null) {
      setState(() {
        _pressed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double buttonHeight = 54;
    final double baseOffset = 6;
    final bool isDisabled = widget.onPressed == null;
    return GestureDetector(
      onTapDown: isDisabled ? null : _onTapDown,
      onTapUp: isDisabled
          ? null
          : (details) {
              _onTapUp(details);
              if (widget.onPressed != null) widget.onPressed!();
            },
      onTapCancel: isDisabled ? null : _onTapCancel,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: SizedBox(
          height: buttonHeight + baseOffset,
          child: Stack(
            children: [
              // Dark green base with offset
              Positioned(
                top: baseOffset,
                left: 0,
                right: 0,
                child: Container(
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              // Animated white box
              AnimatedPositioned(
                duration: const Duration(milliseconds: 80),
                curve: Curves.easeIn,
                top: _pressed ? baseOffset : 0,
                left: 0,
                right: 0,
                child: Container(
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      if (!_pressed)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.text,
                    style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 