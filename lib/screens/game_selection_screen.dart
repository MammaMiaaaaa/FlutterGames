import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'memory_match_screen.dart';
import 'math_racer_screen.dart';

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      GameInfo(
        name: 'Memory Match',
        image: 'assets/images/owl.png',
        color: Colors.lightBlueAccent,
        screen: const MemoryMatchScreen(),
      ),
      GameInfo(
        name: 'Math Racer',
        image: 'assets/images/fox.png',
        color: Colors.pinkAccent,
        screen: const MathRacerScreen(),
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Game Selection!',
                style: GoogleFonts.fredoka(
                  fontWeight: FontWeight.w600,
                  fontSize: 32,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 2.2,
                  mainAxisSpacing: 24,
                ),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  return GameCard(
                    name: game.name,
                    image: game.image,
                    color: game.color,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => game.screen),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String name;
  final String image;
  final Color color;
  final VoidCallback onTap;
  const GameCard({required this.name, required this.image, required this.color, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(image, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.fredoka(
                  fontWeight: FontWeight.w600,
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameInfo {
  final String name;
  final String image;
  final Color color;
  final Widget screen;
  GameInfo({required this.name, required this.image, required this.color, required this.screen});
} 