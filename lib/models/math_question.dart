import 'dart:math';

class MathQuestion {
  final String questionText;
  final int correctAnswer;
  final List<int> options;

  MathQuestion({required this.questionText, required this.correctAnswer, required this.options});

  static MathQuestion generate() {
    final rand = Random();
    int type = rand.nextInt(6); // 0: add, 1: sub, 2: mult, 3: div, 4: missing left, 5: missing right
    int a = 0, b = 0, answer = 0;
    String question = '';
    switch (type) {
      case 0: // Addition: a + b = ?
        a = rand.nextInt(91) + 5;
        b = rand.nextInt(91) + 5;
        answer = a + b;
        if (answer > 100) {
          a = 100 - b;
          answer = a + b;
        }
        question = '$a + $b = ?';
        break;
      case 1: // Subtraction: a - b = ?
        a = rand.nextInt(96) + 5;
        b = rand.nextInt(a - 4) + 5;
        answer = a - b;
        question = '$a - $b = ?';
        break;
      case 2: // Multiplication: a × b = ?
        a = rand.nextInt(12) + 2;
        b = rand.nextInt(12) + 2;
        answer = a * b;
        if (answer > 100) {
          a = 100 ~/ b;
          answer = a * b;
        }
        question = '$a × $b = ?';
        break;
      case 3: // Division: a ÷ b = ?
        b = rand.nextInt(12) + 2;
        answer = rand.nextInt(12) + 2;
        a = b * answer;
        question = '$a ÷ $b = ?';
        break;
      case 4: // Missing left operand: ? × b = c
        b = rand.nextInt(12) + 2;
        answer = rand.nextInt(12) + 2;
        a = b * answer;
        question = '? × $b = $a';
        break;
      case 5: // Missing right operand: a ÷ ? = c
        answer = rand.nextInt(12) + 2;
        b = rand.nextInt(12) + 2;
        a = answer * b;
        question = '$a ÷ ? = $b';
        break;
    }
    // Generate options
    Set<int> optionsSet = {answer};
    while (optionsSet.length < 4) {
      int fake = answer + rand.nextInt(21) - 10;
      if (fake < 0 || fake > 100 || optionsSet.contains(fake)) continue;
      optionsSet.add(fake);
    }
    List<int> options = optionsSet.toList()..shuffle();
    return MathQuestion(
      questionText: question,
      correctAnswer: answer,
      options: options,
    );
  }
} 