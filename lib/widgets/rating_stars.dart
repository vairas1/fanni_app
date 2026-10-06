import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double value;
  final int count;
  final double size;
  const RatingStars(
      {super.key, required this.value, this.count = 0, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 5; i++)
          Icon(
            i <= value.round() ? Icons.star : Icons.star_border,
            size: size,
            color: Colors.amber,
          ),
        if (count > 0)
          Text(' $value ($count)',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
