import 'dart:ui';
import 'package:duo_banking_lab/core/layout/banking_pane_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Compact windows remain single pane', () {
    final panes = bankingPanes(
      size: const Size(390, 844),
      regularWidth: false,
      allowWidthFallback: false,
    );
    expect(panes.primary, const Rect.fromLTWH(0, 0, 390, 844));
    expect(panes.secondary, isNull);
  });
  test('Regular width uses a companion without a hinge', () {
    final panes = bankingPanes(
      size: const Size(951, 669),
      regularWidth: true,
      allowWidthFallback: false,
    );
    expect(panes.secondary, isNotNull);
    expect(panes.secondary!.left - panes.primary.right, 24);
  });
  test('An explicit compact size class takes priority over width', () {
    final panes = bankingPanes(
      size: const Size(1100, 669),
      regularWidth: false,
      allowWidthFallback: false,
    );
    expect(panes.secondary, isNull);
  });
  test('Off-iOS wide windows can use a width fallback', () {
    final panes = bankingPanes(
      size: const Size(1100, 800),
      regularWidth: false,
      allowWidthFallback: true,
    );
    expect(panes.secondary, isNotNull);
  });
  test('Vertical fold uses exact off-center geometry', () {
    const fold = Rect.fromLTWH(400, 0, 40, 669);
    final panes = bankingPanes(
      size: const Size(951, 669),
      regularWidth: true,
      allowWidthFallback: false,
      division: fold,
    );
    expect(panes.primary.right, 400);
    expect(panes.secondary!.left, 440);
    expect(panes.primary.overlaps(fold), isFalse);
    expect(panes.secondary!.overlaps(fold), isFalse);
  });
  test('Horizontal fold stacks two scrolling panes', () {
    const fold = Rect.fromLTWH(0, 400, 669, 40);
    final panes = bankingPanes(
      size: const Size(669, 951),
      regularWidth: true,
      allowWidthFallback: false,
      division: fold,
    );
    expect(panes.primary.bottom, 400);
    expect(panes.secondary!.top, 440);
  });
  test('Unusable narrow side selects the larger clear pane', () {
    const fold = Rect.fromLTWH(180, 0, 40, 669);
    final panes = bankingPanes(
      size: const Size(951, 669),
      regularWidth: true,
      allowWidthFallback: false,
      division: fold,
    );
    expect(panes.secondary, isNull);
    expect(panes.primary.left, 220);
    expect(panes.primary.overlaps(fold), isFalse);
  });
  test('Active camera region is excluded from its pane', () {
    const camera = Rect.fromLTWH(150, 0, 40, 24);
    final panes = bankingPanes(
      size: const Size(390, 844),
      regularWidth: false,
      allowWidthFallback: false,
      occlusions: [camera],
    );
    expect(panes.primary.top, 32);
    expect(panes.primary.overlaps(camera), isFalse);
  });
}
