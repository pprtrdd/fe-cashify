import 'package:flutter/material.dart';

class AppColors {
  static const Color transparent = Colors.transparent;
  
  // --- MARCA Y SUPERFICIES ---
  static const Color primary = Color(0xFF311B92);    // Morado muy oscuro (casi negro)
  static const Color background = Color(0xFFF0F2F5); 
  static const Color surface = Color(0xFFFFFFFF);    
  static const Color textOnPrimary = Color(0xFFFFFFFF); 

  // --- SEMÁNTICA FINANCIERA ACCESIBLE ---
  // Usamos azul para ingresos y naranja vibrante para gastos
  static const Color income = Color(0xFF0056B3);     // Azul fuerte (se distingue del naranja)
  static const Color expense = Color(0xFFD9534F);    // Rojo anaranjado (más brillante)
  static const Color extra = Color(0xFF854000);      // Marrón oscuro

  // --- SEMÁNTICA DE ESTADO ---
  static const Color success = Color(0xFF0056B3);    
  static const Color warning = Color(0xFFFFC107);    // Amarillo ámbar (muy visible)
  static const Color danger = Color(0xFFD9534F);     
  static const Color notification = Color(0xFFFF5252); // Rojo vibrante (muy visible)
  static const Color info = Color(0xFF17A2B8);       

  // --- TEXTOS ---
  static const Color textPrimary = Color(0xFF000000); // Negro puro para máximo contraste
  static const Color textSecondary = Color(0xFF424242); 
  static const Color textLight = Color(0xFF616161);     
  static const Color textFaded = Color(0xFF757575);     

  // --- UI ---
  static const Color divider = Color(0xFFBDBDBD);     // Más oscuro para que se vea
  static const Color border = Color(0xFF9E9E9E);      
  static const Color fieldFill = Color(0xFFE3E6E8);
}