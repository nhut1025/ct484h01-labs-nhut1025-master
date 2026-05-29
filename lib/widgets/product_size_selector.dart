import 'package:flutter/material.dart';

class ProductSizeSelector extends StatelessWidget {
  const ProductSizeSelector({
    super.key,
    required this.availableSizes,
    required this.selectedSize,
    required this.onSizeSelected,
  });

  final List<String> availableSizes;
  final String? selectedSize;
  final void Function(String) onSizeSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableSizes.map((size) {
        return ChoiceChip(
          label: Text(size),
          selected: size == selectedSize,
          onSelected: (_) => onSizeSelected(size),
        );
      }).toList(),
    );
  }
}
