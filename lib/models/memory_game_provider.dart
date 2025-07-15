import 'dart:math';
import 'package:flutter/material.dart';
import 'card_model.dart';

class MemoryGameProvider extends ChangeNotifier {
  int _rows = 4;
  int _columns = 4;
  List<CardModel> _cards = [];
  List<int> _flippedIndices = [];

  int get rows => _rows;
  int get columns => _columns;
  List<CardModel> get cards => _cards;
  List<int> get flippedIndices => _flippedIndices;

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

  void startNewGame(int rows, int cols) {
    _rows = rows;
    _columns = cols;
    _flippedIndices.clear();
    int numPairs = (rows * cols) ~/ 2;
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
    notifyListeners();
  }

  void initializeGame({required int rows, required int columns}) {
    startNewGame(rows, columns);
  }

  void flipCard(int index) {
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
    } else {
      _cards[first] = _cards[first].copyWith(isFlipped: false);
      _cards[second] = _cards[second].copyWith(isFlipped: false);
    }
    _flippedIndices.clear();
    notifyListeners();
  }

  void resetGame() {
    initializeGame(rows: _rows, columns: _columns);
  }
} 