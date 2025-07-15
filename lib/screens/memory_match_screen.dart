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
      provider.initializeGame(rows: provider.rows, columns: provider.columns);
    });
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
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              childAspectRatio: 1,
                            ),
                            itemCount: totalCards,
                            itemBuilder: (context, index) => CardTile(card: cards[index], index: index),
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