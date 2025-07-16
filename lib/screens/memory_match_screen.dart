import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/card_tile.dart';
import '../models/memory_game_provider.dart';

class GridConfig with ChangeNotifier {
  int rows;
  int columns;
  GridConfig({this.rows = 4, this.columns = 4});

  void setRows(int r) {
    rows = r;
    notifyListeners();
  }

  void setColumns(int c) {
    columns = c;
    notifyListeners();
  }
}

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the game with default grid size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MemoryGameProvider>(context, listen: false);
      provider.initializeGame(columns: provider.columns, rows: provider.rows);
      provider.onGameOver = _showResultDialog;
    });
  }

  @override
  void dispose() {
    final provider = Provider.of<MemoryGameProvider>(context, listen: false);
    provider.onGameOver = null;
    super.dispose();
  }

  void _showResultDialog() async {
    final provider = Provider.of<MemoryGameProvider>(context, listen: false);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Time Up!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Final Score: ${provider.score}', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              Text('High Score: ${provider.highScore}', style: const TextStyle(fontSize: 18, color: Colors.green)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                provider.resetGame();
                Navigator.of(context).pop();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MemoryGameProvider>(
      builder: (context, gameProvider, _) {
        final int rows = gameProvider.rows;
        final int columns = gameProvider.columns;
        final cards = gameProvider.cards;
        final int totalCards = cards.length;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Memory Match'),
            actions: [],
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                '/background/bg_forest.png',
                fit: BoxFit.cover,
              ),
              cards.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        const SizedBox(height: kToolbarHeight + 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _TimerDisplay(seconds: gameProvider.timeLeft),
                              _ScoreDisplay(score: gameProvider.score),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 32),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * 0.6,
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final double spacing = 12;
                                        final double totalWidth = constraints.maxWidth;
                                        final double totalHeight = constraints.maxHeight;
                                        final double gridWidth = totalWidth - (spacing * (columns - 1));
                                        final double gridHeight = totalHeight - (spacing * (rows - 1));
                                        final double cardWidth = gridWidth / columns;
                                        final double cardHeight = gridHeight / rows;
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            for (int row = 0; row < rows; row++)
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  for (int col = 0; col < columns; col++)
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        right: col < columns - 1 ? spacing : 0,
                                                        bottom: row < rows - 1 ? spacing : 0,
                                                      ),
                                                      child: SizedBox(
                                                        width: cardWidth,
                                                        height: cardHeight,
                                                        child: CardTile(
                                                          card: cards[row * columns + col],
                                                          index: row * columns + col,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }
}

class _TimerDisplay extends StatelessWidget {
  final int seconds;
  const _TimerDisplay({required this.seconds});
  @override
  Widget build(BuildContext context) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return Row(
      children: [
        const Icon(Icons.timer, color: Color(0xFFFFA000)),
        const SizedBox(width: 4),
        Text('$minutes:$secs', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFFA000))),
      ],
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  final int score;
  const _ScoreDisplay({required this.score});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.green),
        const SizedBox(width: 4),
        Text('$score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
      ],
    );
  }
} 