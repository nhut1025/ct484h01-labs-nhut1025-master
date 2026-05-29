import 'package:flutter/material.dart';

class ProductColorSelector extends StatelessWidget {
  const ProductColorSelector({
    super.key,
    required this.availableColors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  final List<String> availableColors;
  final String? selectedColor;
  final void Function(String) onColorSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableColors.map((color) {
        return ChoiceChip(
          label: Text(color),
          selected: color == selectedColor,
          onSelected: (_) => onColorSelected(color),
        );
      }).toList(),
    );
  }
}
