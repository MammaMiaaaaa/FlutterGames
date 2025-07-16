import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

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
    _generateQuestion();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (timeLeft > 0 && !gameEnded) {
          timeLeft--;
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
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(won ? 'You Win!' : 'Time Up!'),
        content: Text(won
            ? 'Congratulations! The Corgi beat the Rabbit!'
            : 'The Rabbit won the race. Try again!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _startGame();
              });
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).maybePop();
            },
            child: const Text('Exit'),
          ),
        ],
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
              Text(
                'Time Left: ${timeLeft ~/ 60}:${(timeLeft % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Rabbit Track
              _RaceTrack(
                label: 'Rabbit',
                progress: rabbitProgress,
                icon: Icons.pets, // Placeholder for rabbit
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              // Corgi Track
              _RaceTrack(
                label: 'Corgi',
                progress: corgiProgress,
                icon: Icons.pets, // Placeholder for corgi
                color: Colors.brown,
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
              Text('Correct Answers: $correctAnswers / $totalQuestions', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RaceTrack extends StatelessWidget {
  final String label;
  final double progress;
  final IconData icon;
  final Color color;
  const _RaceTrack({required this.label, required this.progress, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            left: (MediaQuery.of(context).size.width - 48 - 32) * progress.clamp(0.0, 1.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  radius: 16,
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
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