import 'package:dollar_x_app/Controller/MainPageController.dart';
import 'package:flutter/material.dart';

/// Widget reutilizable para los campos de conversión de moneda.
class CurrencyTextField extends StatelessWidget {
  final MainPageController controller;
  final String label;
  final String? Function() getErrorText;
  final TextEditingController textController;
  final ValueChanged<String> onChanged;
  final Future<void> Function(BuildContext) onCopy;

  const CurrencyTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.getErrorText,
    required this.textController,
    required this.onChanged,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        errorText: getErrorText(),
        suffixIcon: IconButton(
          onPressed: () => onCopy(context),
          icon: const Icon(Icons.copy),
        ), 
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      controller: textController,
      onChanged: onChanged,
    );
  }
}
