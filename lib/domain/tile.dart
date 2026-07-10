/// A single numbered tile on the board. [id] is stable across moves so the UI
/// can animate a tile's position/scale by identity instead of by cell index.
class Tile {
  final int id;
  final int value;
  final int row;
  final int col;

  /// True only during the move that produced this tile via a merge - lets the
  /// UI trigger a one-shot "pop" animation without re-triggering on rebuilds.
  final bool justMerged;

  /// True only during the move that spawned this tile - lets the UI trigger a
  /// one-shot "appear" animation.
  final bool isNew;

  const Tile({
    required this.id,
    required this.value,
    required this.row,
    required this.col,
    this.justMerged = false,
    this.isNew = false,
  });

  Tile copyWith({
    int? id,
    int? value,
    int? row,
    int? col,
    bool? justMerged,
    bool? isNew,
  }) {
    return Tile(
      id: id ?? this.id,
      value: value ?? this.value,
      row: row ?? this.row,
      col: col ?? this.col,
      justMerged: justMerged ?? this.justMerged,
      isNew: isNew ?? this.isNew,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tile &&
          id == other.id &&
          value == other.value &&
          row == other.row &&
          col == other.col &&
          justMerged == other.justMerged &&
          isNew == other.isNew);

  @override
  int get hashCode => Object.hash(id, value, row, col, justMerged, isNew);

  @override
  String toString() => 'Tile(id: $id, value: $value, row: $row, col: $col)';
}

enum SwipeDirection { up, down, left, right }
