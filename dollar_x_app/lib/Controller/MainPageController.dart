import 'package:flutter/material.dart';

/// Controlador para gestionar los campos de texto de conversión de moneda.
///
/// Esta clase encapsula la lógica de los controladores de texto para el
/// campo de dólares y el campo de bolivares, proporcionando métodos
/// utilitarios y una gestión adecuada del ciclo de vida.
class MainPageController {
  /// Controlador para el campo de texto del monto en dólares.
  final TextEditingController dollarController;

  /// Controlador para el campo de texto del monto en bolivares.
  final TextEditingController bsController;

  /// Constructor que recibe los controladores de texto.
  ///
  /// [dollarController] - Controlador para el monto en dólares.
  /// [bsController] - Controlador para el monto en bolivares.
  /// Ambos parámetros son requeridos y no pueden ser nulos.
  MainPageController({
    required TextEditingController dollarController,
    required TextEditingController bsController,
  })  : dollarController = dollarController,
        bsController = bsController;

  // ==========================================================================
  // UTILIDADES DE ACCESO A DATOS
  // ==========================================================================

  /// Obtiene el valor numérico del campo dólar.
  ///
  /// Retorna [double] si el texto es válido, o `null` si está vacío o es inválido.
  double? get dollarValue => _parseToDouble(dollarController.text);

  /// Obtiene el valor numérico del campo bolivares.
  ///
  /// Retorna [double] si el texto es válido, o `null` si está vacío o es inválido.
  double? get bsValue => _parseToDouble(bsController.text);

  /// Obtiene el texto actual del campo dólar.
  String get dollarText => dollarController.text;

  /// Obtiene el texto actual del campo bolivares.
  String get bsText => bsController.text;

  /// Verifica si el campo dólar tiene contenido válido.
  bool get hasValidDollarValue => dollarValue != null;

  /// Verifica si el campo bolivares tiene contenido válido.
  bool get hasValidBsValue => bsValue != null;

  /// Verifica si al menos uno de los campos tiene un valor válido.
  bool get hasAnyValidValue => hasValidDollarValue || hasValidBsValue;

  // ==========================================================================
  // MÉTODOS DE UTILIDAD
  // ==========================================================================

  /// Convierte el texto a double, manejando diferentes formatos numéricos.
  ///
  /// Soporta:
  /// - Números con punto decimal (ej: "10.50")
  /// - Números con coma decimal (ej: "10,50")
  /// - Números con separadores de miles (ej: "1,000.50")
  double? _parseToDouble(String text) {
    if (text.trim().isEmpty) return null;

    // Normalizar separadores: reemplazar coma por punto solo si no es separador de miles
    String normalizedText = _normalizeNumber(text);
    
    return double.tryParse(normalizedText);
  }

  /// Normaliza el texto numérico para parsing consistente.
  ///
  /// Convierte diferentes formatos regionales a un formato estándar.
  String _normalizeNumber(String text) {
    // Eliminar espacios en blanco
    String result = text.trim();
    
    // Detectar el tipo de separador decimal
    // Si hay comas y puntos, determinar cuál es el decimal
    if (result.contains(',') && result.contains('.')) {
      // Ejemplo: 1,000.50 -> 1000.50
      // La última occurrence de , o . es el separador decimal
      final lastComma = result.lastIndexOf(',');
      final lastDot = result.lastIndexOf('.');
      
      if (lastComma > lastDot) {
        // La coma es el decimal: 1.000,50 -> 1000.50
        result = result.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // El punto es el decimal: 1,000.50 -> 1000.50
        result = result.replaceAll(',', '');
      }
    } else if (result.contains(',')) {
      // Solo comas: verificar si es separador decimal o de miles
      // Si hay más de 3 dígitos después de la coma, es separador de miles
      final parts = result.split(',');
      if (parts.length == 2 && parts[1].length <= 2) {
        // Es separador decimal: 10,50 -> 10.50
        result = result.replaceAll(',', '.');
      } else {
        // Es separador de miles: 1,000 -> 1000
        result = result.replaceAll(',', '');
      }
    }
    
    return result;
  }

  /// Limpia todos los campos de texto.
  void clearAll() {
    dollarController.clear();
    bsController.clear();
  }

  /// Limpia el campo dólar.
  void clearDollar() => dollarController.clear();

  /// Limpia el campo bolivares.
  void clearBs() => bsController.clear();

  /// Actualiza el valor del campo dólar de forma segura.
  ///
  /// Si [value] es `null`, limpia el campo.
  void setDollarValue(double? value) {
    if (value == null) {
      dollarController.clear();
    } else {
      dollarController.text = value.toStringAsFixed(2);
    }
  }

  /// Actualiza el valor del campo bolivares de forma segura.
  ///
  /// Si [value] es `null`, limpia el campo.
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

  /// Valida que el valor del dólar esté dentro de un rango válido.
  ///
  /// [min] - Valor mínimo permitido (por defecto 0).
  /// [max] - Valor máximo permitido (por defecto null, sin límite superior).
  bool isDollarInRange({double min = 0, double? max}) {
    final value = dollarValue;
    if (value == null) return false;
    
    if (value < min) return false;
    if (max != null && value > max) return false;
    
    return true;
  }

  /// Valida que el valor de bolivares esté dentro de un rango válido.
  ///
  /// [min] - Valor mínimo permitido (por defecto 0).
  /// [max] - Valor máximo permitido (por defecto null, sin límite superior).
  bool isBsInRange({double min = 0, double? max}) {
    final value = bsValue;
    if (value == null) return false;
    
    if (value < min) return false;
    if (max != null && value > max) return false;
    
    return true;
  }

  /// Mensaje de error para el campo dólar, o null si es válido.
  String? get dollarError {
    if (dollarText.isEmpty) return null;
    if (dollarValue == null) return 'Valor inválido';
    return null;
  }

  /// Mensaje de error para el campo bolivares, o null si es válido.
  String? get bsError {
    if (bsText.isEmpty) return null;
    if (bsValue == null) return 'Valor inválido';
    return null;
  }

  // ==========================================================================
  // GESTIÓN DEL CICLO DE VIDA
  // ==========================================================================

  /// Libera los recursos del controlador.
  ///
  /// **Importante:** Debe llamarse cuando el widget se destruye
  /// para evitar memory leaks. En StatefulWidget, llamar en dispose().
  void dispose() {
    dollarController.dispose();
    bsController.dispose();
  }
}
