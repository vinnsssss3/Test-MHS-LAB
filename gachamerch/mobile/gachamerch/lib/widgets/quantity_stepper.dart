import 'package:flutter/material.dart';

class QuantityStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          color: value <= min ? Colors.grey : accent,
          onPressed: value <= min ? null : () => onChanged(value - 1),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accent),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          color: value >= max ? Colors.grey : accent,
          onPressed: value >= max ? null : () => onChanged(value + 1),
        ),
      ],
    );
  }
}
