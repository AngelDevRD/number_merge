# Number Merge

Juego de puzzle numerico estilo 2048, hecho en Flutter con Riverpod y arquitectura
limpia ligera. Tablero 4x4, deslizar para mover/combinar fichas, puntaje y mejor
puntaje persistidos, deshacer un movimiento, logros, estadisticas, configuracion
de tema/sonido/vibracion, tutorial inicial y splash animado.

## Funcionalidades

- Tablero 4x4 con logica correcta de 2048: fusion de fichas iguales una sola vez
  por movimiento (sin fusiones dobles en una misma jugada), aparicion de ficha
  nueva (90% valor 2, 10% valor 4) en una celda vacia aleatoria tras cada
  movimiento valido.
- Puntaje y mejor puntaje persistidos localmente y mostrados en pantalla.
- Deshacer el ultimo movimiento (un paso de historial).
- Reiniciar partida con dialogo de confirmacion.
- Vibracion al combinar fichas (HapticFeedback), activable/desactivable en
  configuracion.
- Interruptor de sonido en configuracion (arquitectura de audio lista, ver
  simplificaciones abajo).
- Animaciones de aparicion, movimiento y fusion de fichas (AnimatedPositioned +
  AnimationController con efecto de "pop" al fusionar).
- Logros persistidos: alcanzar 128, 512 y 2048, jugar 10 partidas, acumular
  10000 puntos en total. Pantalla de logros con estado bloqueado/desbloqueado.
- Pantalla de estadisticas: partidas jugadas, tiempo total jugado, mejor ficha
  alcanzada, movimientos totales, puntos acumulados.
- Pantalla de configuracion: tema claro/oscuro/sistema, sonido, vibracion (todo
  persistido).
- Tema Material 3 con `ColorScheme.fromSeed`, claro y oscuro.
- Tutorial superpuesto que se muestra solo en el primer lanzamiento.
- Splash screen animado (fade + scale) hecho con widgets de Flutter, antes de
  la pantalla de inicio.
- Layout responsivo: el tablero se ajusta con `LayoutBuilder` al espacio
  disponible, funciona tanto en telefonos como en tablets sin tamaños fijos.

## Arquitectura

- `lib/domain`: entidades (`Tile`, `Board`, `GameState`) y logica pura del
  juego (`MergeEngine`) en Dart puro, sin imports de Flutter, totalmente
  testeable.
- `lib/data`: repositorios que envuelven `shared_preferences`
  (`SettingsRepository`, `ScoreRepository`, `StatsRepository`,
  `AchievementsRepository`) y `AudioService`.
- `lib/providers`: notifiers de Riverpod que conectan la logica de dominio y
  los repositorios con la UI (`gameProvider`, `settingsProvider`,
  `statsProvider`, `achievementsProvider`).
- `lib/presentation`: pantallas (Home, Game, Settings, Stats, Achievements,
  Splash) y widgets (`BoardWidget`, `TileWidget`, `OnboardingOverlay`),
  navegacion con `go_router`.

## Simplificaciones deliberadas

- **`shared_preferences` en vez de Hive/Isar**: la app solo persiste unos
  pocos valores primitivos (puntajes, contadores, flags de configuracion, ids
  de logros). `shared_preferences` cubre esto sin necesidad de generacion de
  codigo ni de una base de datos embebida — usar Hive/Isar aqui seria
  sobre-ingenieria.
- **Sin archivos de audio reales**: no se incluyen assets de sonido binarios
  (para evitar contenido con copyright o placeholders sinteticos sin valor
  real). `AudioService` (en `lib/data/audio_service.dart`) implementa toda la
  plomeria de reproduccion con `audioplayers`, pero `assetsAvailable` esta en
  `false` a proposito, por lo que las llamadas a `playMove()`, `playMerge()` y
  `playGameOver()` son no-ops seguros. Basta con agregar los archivos reales en
  `assets/sounds/`, declararlos en `pubspec.yaml` y cambiar esa constante a
  `true` para activar el sonido real.
- **Un solo idioma (espanol)**: todos los textos de la interfaz estan en
  espanol directamente en el codigo, sin el andamiaje completo de
  `flutter_intl`/ARB, ya que no hay requerimiento de multi-idioma.
- **Splash simple en vez de launch screens nativas**: en lugar de configurar
  los pipelines nativos de splash de Android/iOS, se uso un widget de Flutter
  con animacion de fade/scale que se muestra antes de la pantalla de inicio.

## Como correrlo

```bash
flutter pub get
flutter run
```

## Tests y analisis

```bash
flutter test
flutter analyze
```

Los tests cubren la logica pura de fusion/movimiento en
`test/merge_engine_test.dart`: fusion correcta en las 4 direcciones, no
fusionar dos veces en el mismo movimiento, deteccion de fin de juego
(`canMove`), condicion de victoria (`hasWon`) y generacion de fichas nuevas
(`spawnRandomTile`).
