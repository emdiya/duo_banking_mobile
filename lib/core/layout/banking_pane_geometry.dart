import 'dart:ui';

/// Local-coordinate panes, shared by foldable and ordinary wide layouts.
class BankingPanes {
  const BankingPanes(this.primary, this.secondary);
  final Rect primary;
  final Rect? secondary;
}

BankingPanes bankingPanes({
  required Size size,
  required bool regularWidth,
  required bool allowWidthFallback,
  Rect? division,
  List<Rect> occlusions = const [],
}) {
  final bounds = Offset.zero & size;
  var primary = bounds;
  Rect? secondary;
  if (division != null && division.overlaps(bounds)) {
    final fold = division.intersect(bounds);
    if (fold.width > 0 && fold.height > 0) {
      if (fold.height >= fold.width &&
          fold.left >= 280 &&
          size.width - fold.right >= 280) {
        primary = Rect.fromLTRB(0, 0, fold.left, size.height);
        secondary = Rect.fromLTRB(fold.right, 0, size.width, size.height);
      } else if (fold.width > fold.height &&
          fold.top >= 180 &&
          size.height - fold.bottom >= 180) {
        primary = Rect.fromLTRB(0, 0, size.width, fold.top);
        secondary = Rect.fromLTRB(0, fold.bottom, size.width, size.height);
      } else {
        // A narrow region should never force an unusably small banking pane.
        final candidates = fold.height >= fold.width
            ? [
                Rect.fromLTRB(0, 0, fold.left, size.height),
                Rect.fromLTRB(fold.right, 0, size.width, size.height),
              ]
            : [
                Rect.fromLTRB(0, 0, size.width, fold.top),
                Rect.fromLTRB(0, fold.bottom, size.width, size.height),
              ];
        primary = candidates.reduce(
          (a, b) => a.width * a.height >= b.width * b.height ? a : b,
        );
      }
    }
  } else if ((regularWidth && size.width >= 664) ||
      (allowWidthFallback && size.width >= 1000)) {
    const gap = 24.0;
    final companionWidth = (size.width * .34).clamp(280.0, 380.0).toDouble();
    primary = Rect.fromLTWH(
      0,
      0,
      size.width - companionWidth - gap,
      size.height,
    );
    secondary = Rect.fromLTWH(
      primary.right + gap,
      0,
      companionWidth,
      size.height,
    );
  }
  return BankingPanes(
    _avoidCamera(primary, occlusions),
    secondary == null ? null : _avoidCamera(secondary, occlusions),
  );
}

Rect _avoidCamera(Rect pane, List<Rect> occlusions) {
  for (final camera in occlusions) {
    if (camera.isEmpty || !camera.overlaps(pane)) continue;
    final blocked = camera.inflate(8).intersect(pane);
    final alternatives = [
      Rect.fromLTRB(pane.left, blocked.bottom, pane.right, pane.bottom),
      Rect.fromLTRB(pane.left, pane.top, pane.right, blocked.top),
      Rect.fromLTRB(blocked.right, pane.top, pane.right, pane.bottom),
      Rect.fromLTRB(pane.left, pane.top, blocked.left, pane.bottom),
    ].where((rect) => !rect.isEmpty).toList();
    if (alternatives.isNotEmpty) {
      pane = alternatives.reduce(
        (a, b) => a.width * a.height >= b.width * b.height ? a : b,
      );
    }
  }
  return pane;
}
