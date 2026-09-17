import 'package:flutter/material.dart';

class AppTheme {
  static const _seedColor = Colors.deepOrange;

  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
  );

  /// Background color for a tile of the given [value], distinct per power of
  /// two so the board is readable at a glance.
  static Color tileColor(int value, Brightness brightness) {
    final map = brightness == Brightness.dark
        ? _darkTileColors
        : _lightTileColors;
    return map[value] ?? map.values.last;
  }

  /// Tinta de la ficha. Se deriva del fondo real que va a tener la ficha, no
  /// del valor: el fondo depende de (valor, brillo) y la tinta dependía solo
  /// del valor, así que las dos tablas se desincronizaban.
  ///
  /// Con eso, en tema oscuro las fichas 2 y 4 -- las únicas que hay al empezar
  /// una partida -- quedaban con tinta `0xFF3F3A36` sobre fondos `0xFF3A3A3C`
  /// y `0xFF48484A`: contraste ~1.0:1, el número era invisible. En tema claro
  /// pasaba lo simétrico de 128 en adelante (blanco sobre dorado, ~1.8:1).
  ///
  /// Elegir la tinta por contraste calculado en vez de por una tabla paralela
  /// hace que el problema no pueda volver: cualquier color de fondo que se
  /// agregue a las paletas recibe automáticamente la tinta legible.
  static Color tileTextColor(int value, Brightness brightness) {
    final background = tileColor(value, brightness);
    return _contrastRatio(_inkDark, background) >=
            _contrastRatio(_inkLight, background)
        ? _inkDark
        : _inkLight;
  }

  static const _inkDark = Color(0xFF241F1B);
  static const _inkLight = Color(0xFFFFFDF8);

  /// Razón de contraste WCAG 2.1 entre dos colores opacos.
  static double _contrastRatio(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final lighter = la > lb ? la : lb;
    final darker = la > lb ? lb : la;
    return (lighter + 0.05) / (darker + 0.05);
  }

  static const _lightTileColors = <int, Color>{
    2: Color(0xFFEEE4DA),
    4: Color(0xFFEDE0C8),
    8: Color(0xFFF2B179),
    16: Color(0xFFF59563),
    32: Color(0xFFF67C5F),
    64: Color(0xFFF65E3B),
    128: Color(0xFFEDCF72),
    256: Color(0xFFEDCC61),
    512: Color(0xFFEDC850),
    1024: Color(0xFFEDC53F),
    2048: Color(0xFFEDC22E),
  };

  /// Paleta oscura. Los naranjas 8-64 estaban en luminancia media (~0.21-0.24),
  /// la zona donde ni tinta clara ni oscura llega a 4.5:1 contra el fondo --
  /// no había color de texto que los hiciera legibles. Se bajaron a la banda
  /// oscura conservando el tono, que además es lo que corresponde a un tema
  /// oscuro: 2-64 son fichas oscuras con número claro, y de 128 en adelante
  /// el dorado brillante con número oscuro marca el tramo "alto" del tablero.
  static const _darkTileColors = <int, Color>{
    2: Color(0xFF3A3A3C),
    4: Color(0xFF48484A),
    8: Color(0xFF8A4E20),
    16: Color(0xFF97561F),
    32: Color(0xFFA2502C),
    64: Color(0xFFAE3E24),
    128: Color(0xFFB89A3E),
    256: Color(0xFFC2A63A),
    512: Color(0xFFCBB234),
    1024: Color(0xFFD4BE2E),
    2048: Color(0xFFDFCA26),
  };
}
