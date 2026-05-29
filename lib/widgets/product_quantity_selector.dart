import 'package:flutter/material.dart';

class ProductQuantitySelector extends StatelessWidget {
  const ProductQuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.selectedSummary,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final String? selectedSummary;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove_circle_outline),
          color: Theme.of(context).colorScheme.primary,
        ),
        Container(
          width: 48,
          alignment: Alignment.center,
          child: Text(
            '$quantity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(Icons.add_circle_outline),
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 16),
        if (selectedSummary != null)
          Expanded(
            child: Text(
              selectedSummary!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}
