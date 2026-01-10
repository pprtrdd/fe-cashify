import 'package:flutter/material.dart';

class AppColors {
  // --- IDENTIDAD DE MARCA ---
  static const Color primary = Colors.deepPurple;
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textOnPrimary = Colors.white;

  // --- SEMÁNTICA FINANCIERA ---
  static const Color income = Colors.green;           // Entradas de dinero
  static const Color expense = Colors.red;            // Salidas de dinero
  static const Color extra = Color(0xFFED6C02);       // Gastos extra / Naranja fuerte

  // --- ESTADOS Y FEEDBACK ---
  static const Color success = Colors.green;          // Éxito / Completado
  static const Color warning = Colors.orange;         // Pendiente / Alerta
  static const Color danger = Colors.red;             // Error / Crítico / Cerrar Sesión
  static const Color notification = Colors.redAccent; // Badges de conteo

  // --- UI NEUTROS Y TEXTOS ---
  static const Color textPrimary = Color(0xFF212121); // Texto principal
  static final Color textLight = Colors.grey[700]!;   // Subtítulos y headers
  static final Color textFaded = Colors.grey[500]!;   // Textos muy secundarios
  static final Color fieldFill = Colors.grey[50]!;    // Fondo de inputs
  static const Color divider = Color(0xFFE0E0E0);     // Líneas divisoras
  static final Color border = Colors.grey[300]!;      // Bordes de tarjetas o tablas
}