import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'card_model.dart';

class MemoryGameProvider extends ChangeNotifier {
  int _columns = 2; // horizontal
  int _rows = 3;    // vertical
  int _level = 1;
  List<CardModel> _cards = [];
  List<int> _flippedIndices = [];
  int _score = 0;
  int _timeLeft = 120;
  Timer? _timer;
  bool _isGameOver = false;
  int _highScore = 0;
  VoidCallback? onGameOver;

  int get rows => _rows;
  int get columns => _columns;
  int get level => _level;
  List<CardModel> get cards => _cards;
  List<int> get flippedIndices => _flippedIndices;
  int get score => _score;
  int get timeLeft => _timeLeft;
  bool get isGameOver => _isGameOver;
  int get highScore => _highScore;

  static const String _highScoreKey = 'high_score';
  static const List<String> _availableImages = [
    'assets/images/signpost.png',
    'assets/images/eggs.png',
    'assets/images/pinecone.png',
    'assets/images/mushroom.png',
    'assets/images/tree stump.png',
    'assets/images/deer.png',
    'assets/images/butterfly.png',
    'assets/images/frog.png',
    'assets/images/bee.png',
    'assets/images/rabbit.png',
    'assets/images/fox.png',
    'assets/images/owl.png',
    'assets/images/raccoon.png',
    'assets/images/beaver.png',
    'assets/images/spider.png',
    'assets/images/boar.png',
    'assets/images/snail.png',
    'assets/images/bear.png',
    'assets/images/hedgehog.png',
    'assets/images/squirrel.png',
  ];

  MemoryGameProvider() {
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt(_highScoreKey) ?? 0;
    notifyListeners();
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highScoreKey, _highScore);
  }

  void startNewGame(int columns, int rows) {
    _columns = columns;
    _rows = rows;
    _level = 1;
    _flippedIndices.clear();
    _score = 0;
    _timeLeft = 120;
    _isGameOver = false;
    _timer?.cancel();
    _startTimer();
    _setupCards(_columns, _rows);
    notifyListeners();
  }

  void initializeGame({required int columns, required int rows}) {
    startNewGame(columns, rows);
  }

  void _setupCards(int columns, int rows) {
    int numPairs = (columns * rows) ~/ 2;
    final mutableImages = List<String>.from(_availableImages);
    mutableImages.shuffle(Random());
    final images = mutableImages.take(numPairs).toList();
    List<CardModel> cardList = [];
    for (int i = 0; i < numPairs; i++) {
      cardList.add(CardModel(id: i, imageAssetPath: images[i], isFlipped: false, isMatched: false));
      cardList.add(CardModel(id: i, imageAssetPath: images[i], isFlipped: false, isMatched: false));
    }
    cardList.shuffle(Random());
    _cards = cardList;
  }

  void _progressLevel() {
    _level++;
    if (_level == 2) {
      _columns = 2;
      _rows = 4;
    } else if (_level == 3) {
      _columns = 3;
      _rows = 4;
    } else if (_level == 4) {
      _columns = 4;
      _rows = 4;
    } else if (_level >= 5) {
      _columns = 4;
      _rows = 5;
    }
    _flippedIndices.clear();
    _setupCards(_columns, _rows);
    notifyListeners();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
        if (_timeLeft == 0) {
          _isGameOver = true;
          _timer?.cancel();
          if (_score > _highScore) {
            _highScore = _score;
            _saveHighScore();
          }
          notifyListeners();
          if (onGameOver != null) {
            onGameOver!();
          }
        }
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void resetTimer() {
    _timer?.cancel();
    _timeLeft = 180;
    _isGameOver = false;
    notifyListeners();
  }

  void flipCard(int index) {
    if (_isGameOver) return;
    if (_cards[index].isFlipped || _cards[index].isMatched || _flippedIndices.length == 2) return;
    _cards[index] = _cards[index].copyWith(isFlipped: true);
    _flippedIndices.add(index);
    notifyListeners();
    if (_flippedIndices.length == 2) {
      Future.delayed(const Duration(milliseconds: 800), _checkMatch);
    }
  }

  void _checkMatch() {
    if (_flippedIndices.length < 2) return;
    int first = _flippedIndices[0];
    int second = _flippedIndices[1];
    if (_cards[first].id == _cards[second].id) {
      _cards[first] = _cards[first].copyWith(isMatched: true);
      _cards[second] = _cards[second].copyWith(isMatched: true);
      _score += 10;
      if (_cards.every((c) => c.isMatched)) {
        // All pairs matched, go to next level
        Future.delayed(const Duration(milliseconds: 600), _progressLevel);
      }
    } else {
      _cards[first] = _cards[first].copyWith(isFlipped: false);
      _cards[second] = _cards[second].copyWith(isFlipped: false);
    }
    _flippedIndices.clear();
    notifyListeners();
  }

  void resetGame() {
    startNewGame(2, 3);
  }
} 