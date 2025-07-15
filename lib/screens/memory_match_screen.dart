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
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  gameProvider.resetGame();
                },
              ),
            ],
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
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: GridView.builder(
                              key: ValueKey('${gameProvider.rows}x${gameProvider.columns}'),
                              padding: const EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                childAspectRatio: 1,
                              ),
                              itemCount: totalCards,
                              itemBuilder: (context, index) => CardTile(card: cards[index], index: index),
                            ),
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