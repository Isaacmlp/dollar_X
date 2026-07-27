import 'package:dollar_x_app/Utils/scrapperUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CurrencyType { usd, eur, usdt }

extension CurrencyTypeExtension on CurrencyType {
  String get code {
    switch (this) {
      case CurrencyType.usd:
        return 'USD';
      case CurrencyType.eur:
        return 'EUR';
      case CurrencyType.usdt:
        return 'USDT';
    }
  }

  String get label {
    switch (this) {
      case CurrencyType.usd:
        return 'Dólares';
      case CurrencyType.eur:
        return 'Euros';
      case CurrencyType.usdt:
        return 'USDT';
    }
  }

  IconData get icon {
    switch (this) {
      case CurrencyType.usd:
        return Icons.attach_money;
      case CurrencyType.eur:
        return Icons.euro_rounded;
      case CurrencyType.usdt:
        return Icons.currency_bitcoin;
    }
  }
}

class MainPageController {
  final TextEditingController dollarController;
  final TextEditingController bsController;

  double dollar = 0.0;
  double euro = 0.0;
  double usdt = 0.0;
  CurrencyType selectedCurrency = CurrencyType.usd;

  MainPageController({
    required TextEditingController dollarController,
    required TextEditingController bsController,
  })  : dollarController = dollarController,
        bsController = bsController;

  double get currentRate {
    switch (selectedCurrency) {
      case CurrencyType.usd:
        return dollar;
      case CurrencyType.eur:
        return euro;
      case CurrencyType.usdt:
        return usdt;
    }
  }

  Future<String?> fetchTasa() async {
    final results = await Future.wait([
      ScrapperUtil.getDolarBcv(),
      ScrapperUtil.getEuroBcv(),
      ScrapperUtil.getUsdtVes(),
    ]);
    final dolarPrecio = results[0];
    final euroPrecio = results[1];
    final usdtPrecio = results[2];
    if (dolarPrecio != null) dollar = dolarPrecio;
    if (euroPrecio != null) euro = euroPrecio;
    if (usdtPrecio != null) {
      usdt = usdtPrecio;
    } else {
      usdt = dollar;
    }
    return dolarPrecio?.toStringAsFixed(2);
  }

  // ==========================================================================
  // CLIPBOARD
  // ==========================================================================

  Future<void> copyToClipboardBs(BuildContext context) async {
    final textToCopy = bsController.text;
    if (textToCopy.isEmpty) return;
    await _copyText(context, textToCopy);
  }

  Future<void> copyToClipboardUSD(BuildContext context) async {
    final textToCopy = dollarController.text;
    if (textToCopy.isEmpty) return;
    await _copyText(context, textToCopy);
  }

  Future<void> _copyText(BuildContext context, String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copiado al portapapeles'),
          backgroundColor: Colors.greenAccent,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al copiar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================================
  // UTILIDADES DE ACCESO A DATOS
  // ==========================================================================

  double? get dollarValue => _parseToDouble(dollarController.text);

  double? get bsValue => _parseToDouble(bsController.text);

  String get dollarText => dollarController.text;

  String get bsText => bsController.text;

  bool get hasValidDollarValue => dollarValue != null;

  bool get hasValidBsValue => bsValue != null;

  bool get hasAnyValidValue => hasValidDollarValue || hasValidBsValue;

  // ==========================================================================
  // MÉTODOS DE UTILIDAD
  // ==========================================================================

  double? _parseToDouble(String text) {
    if (text.trim().isEmpty) return null;
    String normalizedText = _normalizeNumber(text);
    return double.tryParse(normalizedText);
  }

  String _normalizeNumber(String text) {
    String result = text.trim();

    if (result.contains(',') && result.contains('.')) {
      final lastComma = result.lastIndexOf(',');
      final lastDot = result.lastIndexOf('.');

      if (lastComma > lastDot) {
        result = result.replaceAll('.', '').replaceAll(',', '.');
      } else {
        result = result.replaceAll(',', '');
      }
    } else if (result.contains(',')) {
      final parts = result.split(',');
      if (parts.length == 2 && parts[1].length <= 2) {
        result = result.replaceAll(',', '.');
      } else {
        result = result.replaceAll(',', '');
      }
    }

    return result;
  }

  void clearAll() {
    dollarController.clear();
    bsController.clear();
  }

  void clearDollar() => dollarController.clear();

  void clearBs() => bsController.clear();

  void setDollarValue(double? value) {
    if (value == null) {
      dollarController.clear();
    } else {
      dollarController.text = value.toStringAsFixed(2);
    }
  }

  void setBsValue(double? value) {
    if (value == null) {
      bsController.clear();
    } else {
      bsController.text = value.toStringAsFixed(2);
    }
  }

  // ==========================================================================
  // VALIDACIÓN
  // ==========================================================================

  bool isDollarInRange({double min = 0, double? max}) {
    final value = dollarValue;
    if (value == null) return false;

    if (value < min) return false;
    if (max != null && value > max) return false;

    return true;
  }

  bool isBsInRange({double min = 0, double? max}) {
    final value = bsValue;
    if (value == null) return false;

    if (value < min) return false;
    if (max != null && value > max) return false;

    return true;
  }

  String? get dollarError {
    if (dollarText.isEmpty) return null;
    if (dollarValue == null) return 'Valor inválido';
    return null;
  }

  String? get bsError {
    if (bsText.isEmpty) return null;
    if (bsValue == null) return 'Valor inválido';
    return null;
  }

  // ==========================================================================
  // VALIDATORS DE INPUT
  // ==========================================================================

  void validatorsUSD(String value) {
    final hasDecimal = value.contains('.');
    final startsWithZero = value.isNotEmpty && value[0] == '0';
    final isDecimalWithLeadingZero = hasDecimal && startsWithZero;

    if ((value.length > 1) &&
        value[0].contains("0") &&
        !isDecimalWithLeadingZero) {
      dollarController.text = dollarController.text.replaceFirst("0", "");
      value = dollarController.text;
    }
    if (value.isEmpty || dollarController.text.isEmpty) {
      bsController.text = "0.00";
      dollarController.selection = TextSelection.fromPosition(
        TextPosition(offset: dollarController.text.length),
      );
    }
  }

  void validatorsBS(String value) {
    final hasDecimal = value.contains('.');
    final startsWithZero = value.isNotEmpty && value[0] == '0';
    final isDecimalWithLeadingZero = hasDecimal && startsWithZero;

    if ((value.length > 1) &&
        value[0].contains("0") &&
        !isDecimalWithLeadingZero) {
      bsController.text = bsController.text.replaceFirst("0", "");
      value = bsController.text;
    }
    if (value.isEmpty || bsController.text.isEmpty) {
      dollarController.text = "0.00";
      bsController.selection = TextSelection.fromPosition(
        TextPosition(offset: bsController.text.length),
      );
    }
  }

  // ==========================================================================
  // GESTIÓN DEL CICLO DE VIDA
  // ==========================================================================

  void dispose() {
    dollarController.dispose();
    bsController.dispose();
  }
}
