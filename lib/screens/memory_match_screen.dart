import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/card_tile.dart';
import '../models/memory_game_provider.dart';
import '../widgets/score_screen.dart';

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
  bool _isTransitioning = false;
  int _gridKey = 0;

  @override
  void initState() {
    super.initState();
    // Initialize the game with default grid size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MemoryGameProvider>(context, listen: false);
      provider.initializeGame(columns: provider.columns, rows: provider.rows);
      provider.onGameOver = _showResultDialog;
      provider.onLevelTransition = () {
        _onLevelTransition();
        provider.progressLevel();
      };
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ScoreScreen(
          resultText: 'Score ${provider.score}',
          highScoreText: 'High Score: ${provider.highScore}',
          onPlayAgain: () {
            provider.resetGame();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MemoryMatchScreen()),
            );
          },
          onReturn: () {
            provider.resetGame();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  void _onLevelTransition() async {
    setState(() {
      _isTransitioning = true;
    });
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _gridKey++;
      _isTransitioning = false;
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
        final double topPadding = MediaQuery.of(context).padding.top;
        final Size screenSize = MediaQuery.of(context).size;
        final double screenWidth = screenSize.width;
        final double screenHeight = screenSize.height;
        final double headerFontSize = screenWidth * 0.055;
        final double instructionFontSize = screenWidth * 0.052;
        final double iconSize = screenWidth * 0.06;
        final double scoreTimerFontSize = screenWidth * 0.05;
        final double headerPadTop = topPadding + screenHeight * 0.02;
        final double headerPadLR = screenWidth * 0.03;
        final double headerPadBottom = screenHeight * 0.02;
        final double instructionPadTop = screenHeight * 0.02;
        final double instructionPadBottom = screenHeight * 0.005;
        final double gridPadTop = screenHeight * 0.025;
        final double gridPadBottom = screenHeight * 0.06;
        final double gridPadHorizontal = screenWidth * 0.06;
        final double cardSpacing = screenWidth * 0.03;
        final double headerElementMargin = screenWidth * 0.02;
        final double headerElementMarginWide = screenWidth * 0.025;
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                '/background/bg_forest.png',
                fit: BoxFit.cover,
              ),
              Container(
                color: Colors.black.withAlpha(122),
              ),
              // Main content as a Column
              Column(
                children: [
                  // Header Row
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: headerPadTop,
                      left: headerPadLR,
                      right: headerPadLR,
                      bottom: headerPadBottom,
                    ),
                    color: const Color.fromARGB(255, 0, 80, 157),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Close (X) button with left margin
                        Padding(
                          padding: EdgeInsets.only(left: headerElementMarginWide, right: headerElementMargin),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white, size: iconSize),
                            onPressed: () {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                              gameProvider.resetGame();
                            },
                          ),
                        ),
                        // Score box (left half) with horizontal margin
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: headerElementMargin),
                            child: _ScoreBox(score: gameProvider.score, iconSize: iconSize, fontSize: scoreTimerFontSize),
                          ),
                        ),
                        // Timer box (right half) with right margin
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: headerElementMargin, right: headerElementMarginWide),
                            child: _TimerBox(seconds: gameProvider.timeLeft, iconSize: iconSize, fontSize: scoreTimerFontSize),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Instruction text below header
                  Container(
                    width: double.infinity,
                    color: Colors.transparent,
                    padding: EdgeInsets.only(top: instructionPadTop, bottom: instructionPadBottom),
                    child: Text(
                      'Temukan pasangan gambar\nyang sama!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontWeight: FontWeight.w600,
                        fontSize: instructionFontSize,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.4),
                            offset: const Offset(1, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Card grid fills remaining space
                  Expanded(
                    child: cards.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : Padding(
                            padding: EdgeInsets.only(bottom: gridPadBottom, top: gridPadTop),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: gridPadHorizontal),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                switchInCurve: Curves.easeIn,
                                switchOutCurve: Curves.easeOut,
                                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                                child: AbsorbPointer(
                                  absorbing: _isTransitioning,
                                  child: Container(
                                    key: ValueKey(_gridKey),
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final double spacing = cardSpacing;
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

class _ScoreBox extends StatelessWidget {
  final int score;
  final double iconSize;
  final double fontSize;
  const _ScoreBox({required this.score, this.iconSize = 22, this.fontSize = 20});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 44, 86),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icon/icon-star.png',
            width: iconSize,
            height: iconSize,
            color: const Color.fromARGB(255, 255, 238, 7),
          ),
          const SizedBox(width: 8),
          Text('$score', style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: fontSize, color: Colors.white)),
        ],
      ),
    );
  }
}

class _TimerBox extends StatelessWidget {
  final int seconds;
  final double iconSize;
  final double fontSize;
  const _TimerBox({required this.seconds, this.iconSize = 24, this.fontSize = 20});
  @override
  Widget build(BuildContext context) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 44, 86),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.access_time, color: Colors.white, size: iconSize),
          const SizedBox(width: 8),
          Text('$minutes:$secs', style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: fontSize, color: Colors.white)),
        ],
      ),
    );
  }
} 