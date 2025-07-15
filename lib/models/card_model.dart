class CardModel {
  final int id;
  final String imageAssetPath;
  final bool isFlipped;
  final bool isMatched;

  CardModel({
    required this.id,
    required this.imageAssetPath,
    this.isFlipped = false,
    this.isMatched = false,
  });

  CardModel copyWith({
    int? id,
    String? imageAssetPath,
    bool? isFlipped,
    bool? isMatched,
  }) {
    return CardModel(
      id: id ?? this.id,
      imageAssetPath: imageAssetPath ?? this.imageAssetPath,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
} 