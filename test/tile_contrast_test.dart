import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_merge/theme/app_theme.dart';

/// El número de una ficha ilegible rompe el juego entero: no se puede jugar
/// sin leer el tablero. Antes la tinta se elegía por valor y el fondo por
/// (valor, brillo), así que en tema oscuro las fichas 2 y 4 quedaban con
/// texto casi invisible (~1.0:1). Este test fija el invariante para las dos
/// paletas completas, no solo para el caso que falló.
void main() {
  const valores = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048];

  double contraste(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final claro = la > lb ? la : lb;
    final oscuro = la > lb ? lb : la;
    return (claro + 0.05) / (oscuro + 0.05);
  }

  for (final brightness in Brightness.values) {
    group('tema ${brightness.name}', () {
      for (final valor in valores) {
        test('la ficha $valor cumple contraste AA para texto grande', () {
          final fondo = AppTheme.tileColor(valor, brightness);
          final tinta = AppTheme.tileTextColor(valor, brightness);
          // El número se dibuja en bold a ~38% del lado de la celda, muy por
          // encima de 18pt: el umbral aplicable de WCAG 2.1 es 3:1. Se exige
          // 4.5:1, el de texto normal, para dejar margen en pantallas malas.
          expect(
            contraste(tinta, fondo),
            greaterThanOrEqualTo(4.5),
            reason:
                'ficha $valor en tema ${brightness.name}: '
                'tinta $tinta sobre fondo $fondo',
          );
        });
      }
    });
  }
}
