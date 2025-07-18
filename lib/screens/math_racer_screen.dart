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

class _MathRacerGameView extends StatefulWidget {
  const _MathRacerGameView({Key? key}) : super(key: key);

  @override
  State<_MathRacerGameView> createState() => _MathRacerGameViewState();
}

class _MathRacerGameViewState extends State<_MathRacerGameView> {
  bool _navigatedToScoreScreen = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<MathRacerGameProvider>(
      builder: (context, provider, _) {
        final Size screenSize = MediaQuery.of(context).size;
        final double screenWidth = screenSize.width;
        final double screenHeight = screenSize.height;
        final double trackHeight = screenHeight * 0.08; // e.g. 8% of height
        final double trackIconSize = trackHeight * 0.8;
        final double finishLineSize = trackHeight;
        final double trackSpacing = screenHeight * 0.00;
        final double questionBoxPadV = screenHeight * 0.03;
        final double questionBoxPadH = screenWidth * 0.04;
        final double questionFontSize = screenWidth * 0.08;
        final double instructionFontSize = screenWidth * 0.05;
        final double buttonHeight = screenHeight * 0.08;
        final double buttonFontSize = buttonHeight * 0.5;
        final double buttonSpacing = screenHeight * 0.018;
        final double topPad = screenHeight * 0.03;
        final double sidePad = screenWidth * 0.04;
        final options = provider.question.options.toList(); // Local copy
        final double finishLineRightPadding = screenWidth * 0.04; // Adjustable right padding for finish line
        // Navigate to score screen if time is up and not already navigated
        if (provider.gameEnded && !provider.gameWon && !_navigatedToScoreScreen) {
          _navigatedToScoreScreen = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
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
          });
        }
        // Defensive: Only show answer buttons if options.length == 4
        if (options.length != 4) {
          return const Center(child: CircularProgressIndicator());
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
                      SizedBox(height: topPad),
                      // --- Two-Track Race Progress Bar ---
                      Container(
                        width: double.infinity,
                        height: trackHeight * 2 + trackSpacing,
                        child: Column(
                          children: [
                            // Top track: Bingo (Corgi)
                            SizedBox(
                              height: trackHeight,
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Positioned.fill(
                                    child: Image.asset(
                                      'assets/images/race-track.png',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Positioned(
                                    right: finishLineRightPadding,
                                    top: 0,
                                    bottom: 0,
                                    child: Image.asset(
                                      'assets/images/finish-line.png',
                                      height: finishLineSize,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween<double>(
                                      begin: provider.previousPlayerProgress,
                                      end: provider.playerProgress,
                                    ),
                                    duration: const Duration(milliseconds: 400),
                                    builder: (context, value, child) {
                                      return Positioned(
                                        left: (screenWidth - finishLineRightPadding - trackIconSize / 2) * value.clamp(0.0, 1.0),
                                        top: 0,
                                        child: Image.asset(
                                          'assets/bingo/icon-bingo-walk.png',
                                          height: trackIconSize,
                                          fit: BoxFit.contain,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: trackSpacing),
                            // Bottom track: Rabbit
                            SizedBox(
                              height: trackHeight,
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Positioned.fill(
                                    child: Image.asset(
                                      'assets/images/race-track.png',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Positioned(
                                    right: finishLineRightPadding,
                                    top: 0,
                                    bottom: 0,
                                    child: Image.asset(
                                      'assets/images/finish-line.png',
                                      height: finishLineSize,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween<double>(
                                      begin: provider.previousTimerProgress,
                                      end: provider.timerProgress,
                                    ),
                                    duration: const Duration(milliseconds: 400),
                                    builder: (context, value, child) {
                                      return Positioned(
                                        left: (screenWidth - finishLineRightPadding) * value.clamp(0.0, 1.0),
                                        top: 0,
                                        child: Image.asset(
                                          'assets/images/rabbit.png',
                                          height: trackIconSize,
                                          fit: BoxFit.contain,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      // Question Box with instruction
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: sidePad),
                        padding: EdgeInsets.symmetric(vertical: questionBoxPadV, horizontal: questionBoxPadH),
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
                                fontSize: instructionFontSize,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              provider.question.question,
                              style: GoogleFonts.fredoka(
                                fontWeight: FontWeight.w600,
                                fontSize: questionFontSize,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      // Answer Buttons
                      ...List.generate(4, (i) => Padding(
                        padding: EdgeInsets.fromLTRB(sidePad, 10, sidePad, 0),
                        child: SizedBox(
                          height: buttonHeight,
                          width: double.infinity,
                          child: _AnimatedAnswerButton(
                            key: Key('answer_button_$i'),
                            text: '${options[i]}',
                            onPressed: provider.gameEnded ? null : () => _onAnswer(context, provider, options[i]),
                            fontSize: buttonFontSize,
                          ),
                        ),
                      )),
                      const Spacer(),
                      SizedBox(height: screenHeight * 0.02),
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
    if (_navigatedToScoreScreen) return;
    provider.answer(selected);
    if (provider.gameEnded && !_navigatedToScoreScreen) {
      _navigatedToScoreScreen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
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
      });
    }
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
  final double? fontSize;
  const _AnimatedAnswerButton({Key? key, required this.text, required this.onPressed, this.fontSize}) : super(key: key);

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
    final double effectiveFontSize = widget.fontSize ?? 22;
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
                      fontSize: effectiveFontSize,
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