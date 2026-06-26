import 'package:flutter/material.dart';

/// Paleta de marca — Banco Andino.
/// Tomada del logo (flor multicolor) y del degradado calido del portal.
class AppColors {
  AppColors._();

  // Marca principal (rojo Andino)
  static const Color primary = Color(0xFF0D47A1);
  static const Color primaryDark = Color(0xFF082C66);
  static const Color secondary = Color(0xFF42A5F5); // azul claro
  static const Color accent = Color(0xFFE6007E); // magenta

  // Colores del logo (flor) — usados en el isotipo y acentos
  static const Color logoMagenta = Color(0xFFE6007E);
  static const Color logoRojo = Color(0xFFE2001A);
  static const Color logoNaranja = Color(0xFFF39200);
  static const Color logoAmarillo = Color(0xFFFFD500);
  static const Color logoVerde = Color(0xFF95C11F);
  static const Color logoRosa = Color(0xFFEC619F);

  /// Degradado de marca: mezcla de los colores del logo de Banco Andino
  /// (magenta -> rojo -> naranja). Usado en splash, login, AppBars y menu.
  static const List<Color> brandGradient = [
    Color(0xFF0D47A1), // inicio azul oscuro
    Color(0xFF42A5F5), // fin azul claro
  ];

  // Superficies
  static const Color background = Color(0xFFF6F4F5);
  static const Color surface = Colors.white;
  static const Color visitedTile = Color(0xFFE0E0E0);

  // Texto
  static const Color textPrimary = Color(0xFF2A1A1F);
  static const Color textSecondary = Color(0xFF7A6B70);
  static const Color onPrimary = Colors.white;

  // Estados / semaforo
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color danger = Color(0xFFC62828);
  static const Color info = Color(0xFF1565C0);
  static const Color neutral = Color(0xFF8D7B81);

  // Tipos de gestion de cartera (RF-10) — semanticos
  static const Color renovacion = Color(0xFF1976D2);
  static const Color ampliacion = Color(0xFF388E3C);
  static const Color nuevaSolicitud = Color(0xFFF57C00);
  static const Color seguimiento = Color(0xFF757575);
  static const Color recuperacionMora = Color(0xFFD32F2F);
  static const Color desertor = Color(0xFF7B1FA2);

  // Prioridad
  static const Color prioridadAlta = recuperacionMora;
  static const Color prioridadMedia = warning;
  static const Color prioridadNormal = success;
}
