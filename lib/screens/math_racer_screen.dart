import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/score_screen.dart';

class MathRacerScreen extends StatefulWidget {
  const MathRacerScreen({super.key});

  @override
  State<MathRacerScreen> createState() => _MathRacerScreenState();
}

class _MathRacerScreenState extends State<MathRacerScreen> {
  static const int totalTime = 120; // seconds
  static const int totalQuestions = 10;
  int timeLeft = totalTime;
  int correctAnswers = 0;
  int currentQuestion = 0;
  late Timer timer;
  late MathQuestion question;
  bool gameEnded = false;
  bool gameWon = false;
  double playerProgress = 0.0;
  double previousPlayerProgress = 0.0;
  double previousTimerProgress = 0.0;
  double timerProgress = 0.0;
  int highScore = 0;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    timeLeft = totalTime;
    correctAnswers = 0;
    currentQuestion = 0;
    gameEnded = false;
    gameWon = false;
    playerProgress = 0.0;
    previousPlayerProgress = 0.0;
    timerProgress = 0.0;
    previousTimerProgress = 0.0;
    _generateQuestion();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (timeLeft > 0 && !gameEnded) {
          timeLeft--;
          previousTimerProgress = timerProgress;
          timerProgress = 1 - (timeLeft / totalTime);
          if (timeLeft == 0) {
            _endGame(false);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _generateQuestion() {
    question = MathQuestion.generate();
  }

  void _answer(int selected) {
    if (gameEnded) return;
    if (selected == question.answer) {
      setState(() {
        correctAnswers++;
        previousPlayerProgress = playerProgress;
        playerProgress = correctAnswers / totalQuestions;
        if (correctAnswers >= totalQuestions) {
          _endGame(true);
        } else {
          _generateQuestion();
        }
      });
    } else {
      setState(() {
        _generateQuestion();
      });
    }
  }

  void _endGame(bool won) {
    setState(() {
      gameEnded = true;
      gameWon = won;
      timer.cancel();
      if (won) {
        int score = totalTime - timeLeft;
        if (highScore == 0 || score < highScore) {
          highScore = score;
        }
      }
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ScoreScreen(
          resultText: gameWon
              ? 'Finished in ${((totalTime - timeLeft) ~/ 60)}:${((totalTime - timeLeft) % 60).toString().padLeft(2, '0')}!'
              : 'Time Up!',
          highScoreText: highScore > 0
              ? 'Best Time: ${highScore ~/ 60}:${(highScore % 60).toString().padLeft(2, '0')}'
              : '',
          onPlayAgain: () {
            setState(() {
              _startGame();
            });
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MathRacerScreen()),
            );
          },
          onReturn: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  double get rabbitProgress => 1 - (timeLeft / totalTime);
  double get corgiProgress => correctAnswers / totalQuestions;

  @override
  Widget build(BuildContext context) {
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Rabbit Track
              _AnimatedRunnerTrack(
                label: 'Rabbit',
                begin: previousTimerProgress,
                end: timerProgress,
                icon: Icons.pets, // Placeholder for rabbit
                color: Colors.orange,
                showLabel: true,
              ),
              const SizedBox(height: 16),
              // Corgi Track
              _AnimatedRunnerTrack(
                label: 'Corgi',
                begin: previousPlayerProgress,
                end: playerProgress,
                icon: Icons.pets, // Placeholder for corgi
                color: Colors.brown,
                showLabel: true,
              ),
              const SizedBox(height: 32),
              // Question
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    question.question,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Answer Buttons
              ...List.generate(4, (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    onPressed: gameEnded ? null : () => _answer(question.options[i]),
                    child: Text('${question.options[i]}'),
                  ),
                ),
              )),
              const Spacer(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
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