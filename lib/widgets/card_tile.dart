import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/card_model.dart';
import '../models/memory_game_provider.dart';
import 'dart:math';

class CardTile extends StatefulWidget {
  final CardModel card;
  final int index;
  const CardTile({super.key, required this.card, required this.index});

  @override
  State<CardTile> createState() => _CardTileState();
}

class _CardTileState extends State<CardTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnim = Tween<double>(begin: 1, end: 1.00).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    if (widget.card.isFlipped) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(CardTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.card.isFlipped && widget.card.isFlipped) {
      _controller.forward();
    } else if (oldWidget.card.isFlipped && !widget.card.isFlipped) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MemoryGameProvider>(context, listen: false);
    return GestureDetector(
      onTap: () {
        provider.flipCard(widget.index);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final isFront = _flipAnim.value >= 0.5;
          final angle = _flipAnim.value * pi;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: ScaleTransition(
              scale: isFront ? _scaleAnim : const AlwaysStoppedAnimation(1),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isFront ? Colors.white : const Color(0xFFFFA000),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: isFront
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(pi),
                        child: Image.asset(
                          widget.card.imageAssetPath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                        ),
                      )
                    : _PawPrintIcon(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PawPrintIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double iconSize = constraints.maxWidth * 0.45;
        return Image.asset(
          '/card/paw-print.png',
          width: iconSize,
          height: iconSize,
          color: Colors.white,
          fit: BoxFit.contain,
        );
      },
    );
  }
} 