import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class MathRacerGameProvider extends ChangeNotifier {
  static const int totalTime = 60;
  static const int totalQuestions = 10;

  int timeLeft = totalTime;
  int correctAnswers = 0;
  int currentQuestion = 0;
  int highScore = 0;
  bool gameEnded = false;
  bool gameWon = false;
  double playerProgress = 0.0;
  double previousPlayerProgress = 0.0;
  double previousTimerProgress = 0.0;
  double timerProgress = 0.0;
  MathQuestion? question;
  Timer? timer;

  VoidCallback? onGameOver;
  VoidCallback? onGameWon;

  MathRacerGameProvider() {
  }

  void startGame() {
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
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0 && !gameEnded) {
        timeLeft--;
        previousTimerProgress = timerProgress;
        timerProgress = 1 - (timeLeft / totalTime);
        if (timeLeft == 0) {
          _endGame(false);
        }
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void _generateQuestion() {
    question = MathQuestion.generate();
    notifyListeners();
  }

  void answer(int selected) {
    if (gameEnded || question == null) return;
    if (selected == question!.answer) {
      correctAnswers++;
      previousPlayerProgress = playerProgress;
      playerProgress = correctAnswers / totalQuestions;
      if (correctAnswers >= totalQuestions) {
        _endGame(true);
      } else {
        _generateQuestion();
      }
    } else {
      _generateQuestion();
    }
    notifyListeners();
  }

  void _endGame(bool won) {
    if (gameEnded) return;
    gameEnded = true;
    gameWon = won;
    timer?.cancel();
    if (won) {
      int score = totalTime - timeLeft;
      if (highScore == 0 || score < highScore) {
        highScore = score;
      }
      if (onGameWon != null) onGameWon!();
    } else {
      if (onGameOver != null) onGameOver!();
    }
    notifyListeners();
  }

  void resetGame() {
    timer?.cancel();
    startGame();
    notifyListeners();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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